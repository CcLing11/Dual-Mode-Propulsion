clear; clc;
workDir = 'E:\Grade2\双模小论文\IEEE_TAES_orig-research\figures_matlab';
figPath = fullfile(workDir, 'source_figs', 'fig3_3_mode_time_mass.fig');
pdfPath = fullfile(workDir, 'pdf_figures', 'fig3_3_mode_time_mass.pdf');
backupPath = fullfile(workDir, 'source_figs', ['fig3_3_mode_time_mass_before_latex_strings_', datestr(now,'yyyymmdd_HHMMSS'), '.fig']);
copyfile(figPath, backupPath);

hFig = openfig(figPath, 'new', 'visible');
set(hFig, 'Name', 'fig3_3_mode_time_mass', 'NumberTitle', 'off', 'WindowStyle', 'normal');

fixFig33LatexStrings(hFig);
setAllInterpreters(hFig, 'latex');

drawnow;
savefig(hFig, figPath);
exportPdfSameAsFigureSize(hFig, pdfPath);
close(hFig);

fprintf('Updated FIG: %s\n', figPath);
fprintf('Backup FIG:  %s\n', backupPath);
fprintf('Updated PDF: %s\n', pdfPath);

% Re-open once to verify that no invalid LaTeX warnings remain in saved fig.
hCheck = openfig(figPath, 'new', 'invisible');
close(hCheck);
fprintf('Verification reopen finished.\n');

function fixFig33LatexStrings(hFig)
    objs = findall(hFig, '-property', 'String');
    for iObj = 1:numel(objs)
        try
            txt = get(objs(iObj), 'String');
            if ischar(txt) || (isstring(txt) && isscalar(txt))
                txtChar = char(txt);
                txtChar = strtrim(txtChar);
                if strcmp(txtChar, '\alpha_t') || strcmp(txtChar, '$\alpha_t$')
                    set(objs(iObj), 'String', '$\alpha_t$');
                elseif strcmp(txtChar, '\rho_k / \%') || strcmp(txtChar, '\rho_k / %') || strcmp(txtChar, '$\rho_k$ / \%')
                    set(objs(iObj), 'String', '$\rho_k$ / \%');
                else
                    tok = regexp(txtChar, '^\$?m_\{?f\}?\s*=\s*([0-9.]+)\s*kg\$?$', 'tokens', 'once');
                    if ~isempty(tok)
                        set(objs(iObj), 'String', ['$m_{\mathrm{f}} = ' tok{1} '\,\mathrm{kg}$']);
                    end
                end
            elseif iscell(txt)
                set(objs(iObj), 'String', fixCellStrings(txt));
            elseif isstring(txt)
                set(objs(iObj), 'String', fixStringArray(txt));
            end
        catch
        end
    end
end

function out = fixCellStrings(in)
    out = in;
    for i = 1:numel(in)
        if ischar(in{i}) || isstring(in{i})
            s = char(in{i});
            if strcmp(strtrim(s), '\alpha_t')
                out{i} = '$\alpha_t$';
            elseif strcmp(strtrim(s), '\rho_k / \%') || strcmp(strtrim(s), '\rho_k / %')
                out{i} = '$\rho_k$ / \%';
            else
                tok = regexp(strtrim(s), '^\$?m_\{?f\}?\s*=\s*([0-9.]+)\s*kg\$?$', 'tokens', 'once');
                if ~isempty(tok)
                    out{i} = ['$m_{\mathrm{f}} = ' tok{1} '\,\mathrm{kg}$'];
                end
            end
        end
    end
end

function out = fixStringArray(in)
    out = strings(size(in));
    for i = 1:numel(in)
        c = fixCellStrings({char(in(i))});
        out(i) = string(c{1});
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
