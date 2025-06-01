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
input_tree = "λa (a IO/Done/tag IO/MAGIC λb (b Tree/Node/tag λc (c Tree/Node/tag λd (d Tree/Leaf/tag λe (e Point/tag λf (f Map/Node/tag λg (g Maybe/Some/tag 0.550) λh (h Map/Node/tag Maybe/None λi (i Map/Node/tag Maybe/Noneλj (j Map/Node/tag Maybe/None Map/Leaf λk (k Map/Node/tag λl (l Maybe/Some/tag 2.060) Map/Leaf Map/Leaf)) λm(m Map/Node/tag λn (n Maybe/Some/tag -5.890) Map/Leaf Map/Leaf)) λo (o Map/Node/tag λp (p Maybe/Some/tag 5.080) Map/Leaf λq (q Map/Node/tag λr (r Maybe/Some/tag -10.950) Map/Leaf Map/Leaf))) λs (s Map/Node/tag λt (t Maybe/Some/tag 8.620) λu (u Map/Node/tag Maybe/None λv (v Map/Node/tag Maybe/None Map/Leaf λw (w Map/Node/tag λx (x Maybe/Some/tag 1.160) Map/Leaf Map/Leaf)) λy (y Map/Node/tag λz (z Maybe/Some/tag -10.150) Map/Leaf Map/Leaf)) λab (ab Map/Node/tag λbb (bb Maybe/Some/tag 1.740) Map/Leaf λcb (cb Map/Node/tag λdb (db Maybe/Some/tag 8.330) Map/Leaf Map/Leaf)))) 0)) λeb (eb Tree/Leaf/tag λfb (fb Point/tag λgb (gb Map/Node/tag λhb (hb Maybe/Some/tag -9.710) λib (ib Map/Node/tag Maybe/None λjb (jb Map/Node/tag Maybe/None λkb (kb Map/Node/tag Maybe/None Map/Leaf λlb (lb Map/Node/tag λmb (mb Maybe/Some/tag 2.950) Map/Leaf Map/Leaf)) λnb (nb Map/Node/tag λob (ob Maybe/Some/tag -5.150) Map/Leaf Map/Leaf)) λpb (pb Map/Node/tag λqb (qb Maybe/Some/tag -12.140) Map/Leaf λrb (rb Map/Node/tag λsb (sb Maybe/Some/tag -3.410) Map/Leaf Map/Leaf))) λtb (tb Map/Node/tag λub (ub Maybe/Some/tag 2.740) λvb (vb Map/Node/tag Maybe/None λwb (wb Map/Node/tag Maybe/None Map/Leaf λxb (xb Map/Node/tag λyb (yb Maybe/Some/tag -7.240) Map/Leaf Map/Leaf)) λzb (zb Map/Node/tag λac (ac Maybe/Some/tag 2.160) Map/Leaf Map/Leaf)) λbc (bc Map/Node/tag λcc (cc Maybe/Some/tag 12.360) Map/Leaf λdc (dc Map/Node/tag λec (ec Maybe/Some/tag -1.400) Map/Leaf Map/Leaf)))) 0))) λfc (fc Tree/Node/tag λgc (gc Tree/Leaf/tag λhc (hc Point/tag λic (ic Map/Node/tag λjc (jc Maybe/Some/tag 0.960) λkc (kc Map/Node/tag Maybe/None λlc (lc Map/Node/tag Maybe/None λmc (mc Map/Node/tag Maybe/None Map/Leaf λnc (nc Map/Node/tag λoc (oc Maybe/Some/tag 3.690) Map/Leaf Map/Leaf)) λpc (pc Map/Node/tag λqc (qc Maybe/Some/tag 11.230) Map/Leaf Map/Leaf)) λrc (rc Map/Node/tag λsc (sc Maybe/Some/tag -6.310) Map/Leaf λtc (tc Map/Node/tag λuc (uc Maybe/Some/tag -3.620) Map/Leaf Map/Leaf))) λvc (vc Map/Node/tag λwc (wc Maybe/Some/tag -6.750) λxc (xc Map/Node/tag Maybe/None λyc (yc Map/Node/tag Maybe/None Map/Leaf λzc (zc Map/Node/tag λad (ad Maybe/Some/tag -2.100) Map/Leaf Map/Leaf)) λbd (bd Map/Node/tag λcd (cd Maybe/Some/tag 6.360) Map/Leaf Map/Leaf)) λdd (dd Map/Node/tag λed (ed Maybe/Some/tag 10.880) Map/Leaf λfd (fd Map/Node/tag λgd (gd Maybe/Some/tag -8.120) Map/Leaf Map/Leaf)))) 3)) λhd (hd Tree/Node/tag λid (id Tree/Leaf/tag λjd (jd Point/tag λkd (kd Map/Node/tag λld (ld Maybe/Some/tag -9.120) λmd (md Map/Node/tag Maybe/None λnd (nd Map/Node/tag Maybe/None λod (od Map/Node/tag Maybe/None Map/Leaf λpd (pd Map/Node/tag λqd (qd Maybe/Some/tag -4.430) Map/Leaf Map/Leaf)) λrd (rd Map/Node/tag λsd (sd Maybe/Some/tag -5.010) Map/Leaf Map/Leaf)) λtd (td Map/Node/tag λud (ud Maybe/Some/tag 7.860) Map/Leaf λvd (vd Map/Node/tag λwd (wd Maybe/Some/tag -5.430) Map/Leaf Map/Leaf))) λxd (xd Map/Node/tag λyd (yd Maybe/Some/tag 9.210) λzd (zd Map/Node/tag Maybe/Noneλae (ae Map/Node/tag Maybe/None Map/Leaf λbe (be Map/Node/tag λce (ce Maybe/Some/tag -3.800) Map/Leaf Map/Leaf)) λde (de Map/Node/tag λee (ee Maybe/Some/tag -7.280) Map/Leaf Map/Leaf)) λfe (fe Map/Node/tag λge (ge Maybe/Some/tag -4.440) Map/Leaf λhe (he Map/Node/tag λie (ie Maybe/Some/tag -1.320) Map/Leaf Map/Leaf)))) 0)) λje (je Tree/Leaf/tag λke (ke Point/tag λle (le Map/Node/tag λme (me Maybe/Some/tag 3.230) λne (ne Map/Node/tagMaybe/None λoe (oe Map/Node/tag Maybe/None λpe (pe Map/Node/tag Maybe/None Map/Leaf λqe (qe Map/Node/tag λre(re Maybe/Some/tag -1.860) Map/Leaf Map/Leaf)) λse (se Map/Node/tag λte (te Maybe/Some/tag 3.400) Map/Leaf Map/Leaf)) λue (ue Map/Node/tag λve (ve Maybe/Some/tag -5.200) Map/Leaf λwe (we Map/Node/tag λxe (xe Maybe/Some/tag -6.300) Map/Leaf Map/Leaf))) λye (ye Map/Node/tag λze (ze Maybe/Some/tag -5.760) λaf (af Map/Node/tag Maybe/None λbf (bf Map/Node/tag Maybe/None Map/Leaf λcf (cf Map/Node/tag λdf (df Maybe/Some/tag -8.170) Map/Leaf Map/Leaf)) λef (ef Map/Node/tag λff (ff Maybe/Some/tag 5.420) Map/Leaf Map/Leaf)) λgf (gf Map/Node/tag λhf(hf Maybe/Some/tag -3.910) Map/Leaf λif (if Map/Node/tag λjf (jf Maybe/Some/tag 1.230) Map/Leaf Map/Leaf))))0))))))"

formatted_tree = indent_tree(input_tree)
print(formatted_tree)