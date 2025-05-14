def indent_tree(tree_str):
    indent_level = 0
    result = []
    i = 0

    while i < len(tree_str):
        char = tree_str[i]
        # Increase indent after an opening parenthesis
        if char == '(':
            indent_level += 1
            result.append(' ' * (2 * (indent_level - 1)) + char)
        # Decrease indent before a closing parenthesis
        elif char == ')':
            indent_level -= 1
            result.append('\n' + ' ' * (2 * indent_level) + char)
        # New line after certain tags for better readability
        elif char == 'λ' or (i > 0 and tree_str[i - 1] == ' ' and char.isalnum()):
            result.append('\n' + ' ' * (2 * indent_level) + char)
        else:
            result.append(char)
        i += 1

    # Join the list into a single formatted string
    return ''.join(result)


# Example usage
input_tree = " λa (a Tree/Node/tag λb (b Tree/Node/tag λc (c Tree/Leaf/tag λd (d Point/tag λe (e Map/Node/tag λf (f Maybe/Some/tag 3.400) λg (g Map/Node/tag Maybe/None Map/Leaf λh (h Map/Node/tag λi (i Maybe/Some/tag 1.300) Map/Leaf Map/Leaf)) λj (j Map/Node/tag λk (k Maybe/Some/tag 1.200) Map/Leaf λl (l Map/Node/tag λm (m Maybe/Some/tag 1.400) Map/Leaf Map/Leaf))) 2)) λn (n Tree/Leaf/tag λo (o Point/tag λp (p Map/Node/tag λq (q Maybe/Some/tag 15.100) λr (r Map/Node/tag Maybe/None Map/Leaf λs (s Map/Node/tag λt (t Maybe/Some/tag 1.300) Map/Leaf Map/Leaf)) λu (u Map/Node/tag λv (v Maybe/Some/tag 1.200) Map/Leaf λw (w Map/Node/tag λx (x Maybe/Some/tag 1.400) Map/Leaf Map/Leaf))) 3))) λy (y Tree/Leaf/tag λz (z Point/tag λab (ab Map/Node/tag λbb (bb Maybe/Some/tag 0.700) λcb (cb Map/Node/tag Maybe/None Map/Leaf λdb(db Map/Node/tag λeb (eb Maybe/Some/tag 1.300) Map/Leaf Map/Leaf)) λfb (fb Map/Node/tag λgb (gb Maybe/Some/tag 1.200) Map/Leaf λhb (hb Map/Node/tag λib (ib Maybe/Some/tag 1.400) Map/Leaf Map/Leaf))) 1)))"

formatted_tree = indent_tree(input_tree)
print(formatted_tree)