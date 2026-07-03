clear; clc;
figPath = 'E:\Grade2\双模小论文\IEEE_TAES_orig-research\figures_matlab\source_figs\fig3_3_mode_time_mass.fig';
hFig = openfig(figPath, 'new', 'invisible');
objs = findall(hFig, '-property', 'String');
for i = 1:numel(objs)
    typ = '';
    try, typ = get(objs(i), 'Type'); catch, end
    interp = '';
    try, interp = get(objs(i), 'Interpreter'); catch, end
    str = get(objs(i), 'String');
    if iscell(str)
        str = strjoin(string(str), ' | ');
    elseif isstring(str)
        str = strjoin(str, ' | ');
    else
        str = string(str);
    end
    fprintf('OBJ %02d | Type=%s | Interpreter=%s | String=%s\n', i, typ, interp, str);
end
close(hFig);
