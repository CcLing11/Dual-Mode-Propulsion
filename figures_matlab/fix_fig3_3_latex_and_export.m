clear; clc;
workDir = 'E:\Grade2\双模小论文\IEEE_TAES_orig-research\figures_matlab';
figPath = fullfile(workDir, 'source_figs', 'fig3_3_mode_time_mass.fig');
pdfPath = fullfile(workDir, 'pdf_figures', 'fig3_3_mode_time_mass.pdf');
backupPath = fullfile(workDir, 'source_figs', ['fig3_3_mode_time_mass_before_latex_', datestr(now,'yyyymmdd_HHMMSS'), '.fig']);
copyfile(figPath, backupPath);

hFig = openfig(figPath, 'new', 'visible');
set(hFig, 'Name', 'fig3_3_mode_time_mass', 'NumberTitle', 'off', 'WindowStyle', 'normal');

escapePercentStringsForLatex(hFig);
setAllInterpreters(hFig, 'latex');

drawnow;
savefig(hFig, figPath);
exportPdfSameAsFigureSize(hFig, pdfPath);
close(hFig);

fprintf('Updated FIG: %s\n', figPath);
fprintf('Backup FIG:  %s\n', backupPath);
fprintf('Updated PDF: %s\n', pdfPath);

function setAllInterpreters(hFig, interpreterName)
    objs = findall(hFig, '-property', 'Interpreter');
    for iObj = 1:numel(objs)
        try
            set(objs(iObj), 'Interpreter', interpreterName);
        catch
        end
    end

    axs = findall(hFig, 'Type', 'axes');
    for iAx = 1:numel(axs)
        try
            set(axs(iAx), 'TickLabelInterpreter', interpreterName);
        catch
        end
    end
end

function escapePercentStringsForLatex(hFig)
    objs = findall(hFig, '-property', 'String');
    for iObj = 1:numel(objs)
        try
            txt = get(objs(iObj), 'String');
            txt = escapePercentText(txt);
            set(objs(iObj), 'String', txt);
        catch
        end
    end
end

function out = escapePercentText(in)
    if iscell(in)
        out = cellfun(@escapePercentText, in, 'UniformOutput', false);
        return;
    end
    if isstring(in)
        out = arrayfun(@(x) string(escapePercentText(char(x))), in);
        return;
    end
    out = char(in);
    token = '__PERCENT_TOKEN__';
    out = strrep(out, '\%', token);
    out = strrep(out, '%', '\%');
    out = strrep(out, token, '\%');
end

function exportPdfSameAsFigureSize(hFig, pdfPath)
    set(hFig, 'Units', 'pixels');
    pos = get(hFig, 'Position');
    dpi = get(0, 'ScreenPixelsPerInch');
    if isempty(dpi) || ~isnumeric(dpi) || dpi <= 0
        dpi = 96;
    end

    widthIn = pos(3) / dpi;
    heightIn = pos(4) / dpi;
    set(hFig, 'PaperUnits', 'inches', ...
        'PaperPositionMode', 'manual', ...
        'PaperPosition', [0, 0, widthIn, heightIn], ...
        'PaperSize', [widthIn, heightIn], ...
        'InvertHardcopy', 'off');
    print(hFig, pdfPath, '-dpdf', '-r300');
end
