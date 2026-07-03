clear; clc;
workDir = 'E:\Grade2\双模小论文\IEEE_TAES_orig-research\figures_matlab';
figPath = fullfile(workDir, 'source_figs', 'fig3_3_mode_time_mass.fig');
pdfPath = fullfile(workDir, 'pdf_figures', 'fig3_3_mode_time_mass.pdf');
backupPath = fullfile(workDir, 'source_figs', ['fig3_3_mode_time_mass_before_legend_', datestr(now,'yyyymmdd_HHMMSS'), '.fig']);
copyfile(figPath, backupPath);

hFig = openfig(figPath, 'new', 'visible');
set(hFig, 'Name', 'fig3_3_mode_time_mass', 'NumberTitle', 'off', 'WindowStyle', 'normal');

fixFig33LatexStrings(hFig);
fixFig33LegendLabels(hFig);
setAllInterpreters(hFig, 'latex');

drawnow;
savefig(hFig, figPath);
exportPdfSameAsFigureSize(hFig, pdfPath);
close(hFig);

fprintf('Updated FIG: %s\n', figPath);
fprintf('Backup FIG:  %s\n', backupPath);
fprintf('Updated PDF: %s\n', pdfPath);

hCheck = openfig(figPath, 'new', 'invisible');
legs = findall(hCheck, 'Type', 'legend');
for iLeg = 1:numel(legs)
    disp(get(legs(iLeg), 'String'));
end
close(hCheck);

function fixFig33LegendLabels(hFig)
    legs = findall(hFig, 'Type', 'legend');
    if isempty(legs)
        legs = findall(hFig, 'Tag', 'legend');
    end
    for iLeg = 1:numel(legs)
        labels = get(legs(iLeg), 'String');
        if numel(labels) >= 3
            labels{1} = 'Coast';
            labels{2} = 'Mode 1';
            labels{3} = 'Mode 2';
            set(legs(iLeg), 'String', labels, 'Interpreter', 'latex');
        end
    end
end

function fixFig33LatexStrings(hFig)
    objs = findall(hFig, '-property', 'String');
    for iObj = 1:numel(objs)
        try
            txt = get(objs(iObj), 'String');
            if ischar(txt) || (isstring(txt) && isscalar(txt))
                set(objs(iObj), 'String', fixFig33LatexText(char(txt)));
            elseif iscell(txt)
                for iCell = 1:numel(txt)
                    if ischar(txt{iCell}) || isstring(txt{iCell})
                        txt{iCell} = fixFig33LatexText(char(txt{iCell}));
                    end
                end
                set(objs(iObj), 'String', txt);
            elseif isstring(txt)
                for iStr = 1:numel(txt)
                    txt(iStr) = string(fixFig33LatexText(char(txt(iStr))));
                end
                set(objs(iObj), 'String', txt);
            end
        catch
        end
    end
end

function out = fixFig33LatexText(in)
    txt = strtrim(char(in));
    out = char(in);
    if strcmp(txt, '\alpha_t')
        out = '$\alpha_t$';
        return;
    end
    if strcmp(txt, '\rho_k / \%') || strcmp(txt, '\rho_k / %')
        out = '$\rho_k$ / \%';
        return;
    end
    if startsWith(txt, 'm_f =')
        val = regexp(txt, '([0-9.]+)', 'match', 'once');
        if ~isempty(val)
            out = ['$m_{\mathrm{f}} = ' val '\,\mathrm{kg}$'];
        end
    end
end

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
