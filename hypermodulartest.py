import os
import ast
import networkx as nx
import community as community_louvain


def extract_functions_and_calls(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        try:
            node = ast.parse(f.read(), filename=filepath)
        except SyntaxError:
            return [], []

    functions = []
    calls = []

    class FuncDefVisitor(ast.NodeVisitor):
        def __init__(self):
            self.current_func = None

        def visit_FunctionDef(self, func_node):
            func_name = func_node.name
            functions.append(func_name)
            self.current_func = func_name
            self.generic_visit(func_node)
            self.current_func = None

        def visit_Call(self, call_node):
            if self.current_func is not None:
                if isinstance(call_node.func, ast.Name):
                    callee = call_node.func.id
                    calls.append((self.current_func, callee))
                elif isinstance(call_node.func, ast.Attribute):
                    callee = call_node.func.attr
                    calls.append((self.current_func, callee))
            self.generic_visit(call_node)

    visitor = FuncDefVisitor()
    visitor.visit(node)

    return functions, calls


def build_multilevel_graph(source_dir):
    G = nx.DiGraph()

    folder_nodes = set()
    file_nodes = set()
    function_nodes = set()

    file_to_folder = {}
    file_functions = {}
    function_calls = []

    for root, dirs, files in os.walk(source_dir):
        rel_folder = os.path.relpath(root, source_dir)
        if rel_folder == '.':
            rel_folder = ''
        folder_nodes.add(rel_folder)
        for f in files:
            if f.endswith('.py'):
                rel_file = os.path.join(rel_folder, f) if rel_folder else f
                file_nodes.add(rel_file)
                file_to_folder[rel_file] = rel_folder

                abs_path = os.path.join(root, f)
                funcs, calls = extract_functions_and_calls(abs_path)
                file_functions[rel_file] = funcs

                for caller, callee in calls:
                    caller_full = f"{rel_file}::{caller}"
                    callee_full = f"{rel_file}::{callee}"
                    function_calls.append((caller_full, callee_full))

    for folder in folder_nodes:
        G.add_node(f"folder::{folder}", type='folder')
    for file in file_nodes:
        G.add_node(f"file::{file}", type='file')
    for file, funcs in file_functions.items():
        for func in funcs:
            G.add_node(f"func::{file}::{func}", type='function')

    for file, funcs in file_functions.items():
        folder = file_to_folder[file]
        G.add_edge(f"file::{file}", f"folder::{folder}")
        for func in funcs:
            G.add_edge(f"func::{file}::{func}", f"file::{file}")

    for caller, callee in function_calls:
        if f"func::{caller}" in G.nodes and f"func::{callee}" in G.nodes:
            G.add_edge(f"func::{caller}", f"func::{callee}")

    return G


def calculate_layer_metrics(G, layer_prefix):
    nodes = [n for n, attr in G.nodes(data=True) if n.startswith(layer_prefix)]
    subgraph = G.subgraph(nodes).to_undirected()

    if subgraph.number_of_nodes() == 0:
        return 0, 0, 0, 0

    partition = community_louvain.best_partition(subgraph)
    modularity = community_louvain.modularity(partition, subgraph)

    num_modules = len(set(partition.values()))
    num_nodes = subgraph.number_of_nodes()
    M_r = num_modules / num_nodes if num_nodes > 0 else 0

    inter_edges = sum(1 for u, v in subgraph.edges() if partition.get(u) != partition.get(v))
    S = 1 - (inter_edges / subgraph.number_of_edges()) if subgraph.number_of_edges() > 0 else 0

    module_sizes = {mod: sum(1 for n in partition if partition[n] == mod) for mod in set(partition.values())}
    max_module_size = max(module_sizes.values()) if module_sizes else 0
    H_m = 1 - (max_module_size / num_nodes) if num_nodes > 0 else 0

    return modularity, M_r, S, H_m


def calculate_hmi_multilevel(G, weights=None):
    if weights is None:
        weights = {
            'func': {'w': 0.5, 'a': 0.25, 'b': 0.25, 'c': 0.25, 'd': 0.25},
            'file': {'w': 0.3, 'a': 0.25, 'b': 0.25, 'c': 0.25, 'd': 0.25},
            'folder': {'w': 0.2, 'a': 0.25, 'b': 0.25, 'c': 0.25, 'd': 0.25}
        }

    results = {}
    total_HMI = 0

    for layer in ['func', 'file', 'folder']:
        Q, M_r, S, H_m = calculate_layer_metrics(G, f'{layer}::')
        hmi = weights[layer]['a'] * Q + weights[layer]['b'] * M_r + weights[layer]['c'] * S + weights[layer]['d'] * H_m
        results[layer] = {'Q': Q, 'M_r': M_r, 'S': S, 'H_m': H_m, 'hmi': hmi}
        total_HMI += weights[layer]['w'] * hmi

    results['HMI'] = total_HMI
    return results

