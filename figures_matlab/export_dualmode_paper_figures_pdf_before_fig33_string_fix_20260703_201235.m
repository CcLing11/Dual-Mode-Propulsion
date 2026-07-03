%% Export selected dual-mode paper figures to tight PDF files
% This script opens existing MATLAB .fig files and exports them as PDFs.
% It intentionally does not redraw curves or modify axes/legend/font styles.
%
% Directory layout expected:
%   this script
%   source_figs\*.fig
%   pdf_figures\*.pdf  (generated)

clear; clc;

scriptPath = mfilename('fullpath');
if isempty(scriptPath)
    scriptDir = pwd;
else
    scriptDir = fileparts(scriptPath);
end

figDir = fullfile(scriptDir, 'source_figs');
pdfDir = fullfile(scriptDir, 'pdf_figures');
if ~exist(pdfDir, 'dir')
    mkdir(pdfDir);
end

keepFiguresOpen = true;

figs = {
    'fig3_1_trajectory_3d.fig',        'fig3_1_trajectory_3d.pdf'
    'fig_02b_trajectory_xy_aa_0p60_mf_0784p651.fig', 'fig_02b_trajectory_xy_aa_0p60_mf_0784p651.pdf'
    'fig_02b_trajectory_xy_aa_0p75_mf_1013p061.fig', 'fig_02b_trajectory_xy_aa_0p75_mf_1013p061.pdf'
    'fig_02b_trajectory_xy_aa_0p90_mf_1209p719.fig', 'fig_02b_trajectory_xy_aa_0p90_mf_1209p719.pdf'
    'fig3_2_mode_switching.fig',       'fig3_2_mode_switching.pdf'
    'fig3_3_mode_time_mass.fig',       'fig3_3_mode_time_mass.pdf'
    'fig3_4a_elements_aei.fig',        'fig3_4a_elements_aei.pdf'
    'fig3_4b_elements_angles.fig',     'fig3_4b_elements_angles.pdf'
    'fig3_5_remaining_mass.fig',       'fig3_5_remaining_mass.pdf'
    'fig3_6_gain_vs_low_thrust.fig',   'fig3_6_gain_vs_low_thrust.pdf'
    'fig3_7_gain_vs_noncoast.fig',     'fig3_7_gain_vs_noncoast.pdf'
    'fig3_8_mode_fractions.fig',       'fig3_8_mode_fractions.pdf'
    'fig3_9_mass_gain_boundary.fig',   'fig3_9_mass_gain_boundary.pdf'
    'fig3_10_threshold_curves.fig',    'fig3_10_threshold_curves.pdf'
    'fig3_11_gain_vs_fraction.fig',    'fig3_11_gain_vs_fraction.pdf'
    'fig3_12_gain_efficiency.fig',     'fig3_12_gain_efficiency.pdf'
};

fprintf('Source fig folder: %s\n', figDir);
fprintf('Output PDF folder: %s\n\n', pdfDir);

for k = 1:size(figs, 1)
    figName = figs{k, 1};
    pdfName = figs{k, 2};
    figPath = fullfile(figDir, figName);
    pdfPath = fullfile(pdfDir, pdfName);

    if ~exist(figPath, 'file')
        warning('Missing figure file: %s', figPath);
        continue;
    end

    fprintf('[%02d/%02d] %s -> %s\n', k, size(figs, 1), figName, pdfName);

    hFig = openfig(figPath, 'new', 'visible');
    set(hFig, 'Name', erase(pdfName, '.pdf'), ...
        'NumberTitle', 'off', ...
        'WindowStyle', 'normal');

    drawnow;
    placeFigureTopLeft(hFig);

    % Apply only text/interpreter fixes requested after manual .fig edits.
    % Legend positions and axis limits are preserved from source_figs.
    applyPaperFigureTweaks(hFig, pdfName);
    drawnow;
    exportPdfSameAsFigureSize(hFig, pdfPath);

    if ~keepFiguresOpen
        close(hFig);
    end
end

fprintf('\nFinished. PDFs saved in:\n%s\n', pdfDir);

function placeFigureTopLeft(hFig)
% Place every figure with the same top-left screen anchor.
% If a figure is larger than the visible screen area, scale it down
% uniformly so that the title bar remains reachable.

    set(hFig, 'Units', 'pixels');
    pos = get(hFig, 'Position');
    screen = get(0, 'ScreenSize');  % [left bottom width height]

    leftMargin = 80;
    topMargin = 110;
    rightMargin = 80;
    bottomMargin = 80;

    maxW = max(300, screen(3) - leftMargin - rightMargin);
    maxH = max(250, screen(4) - topMargin - bottomMargin);

    scale = min([1, maxW / pos(3), maxH / pos(4)]);
    newW = pos(3) * scale;
    newH = pos(4) * scale;

    newLeft = screen(1) + leftMargin;
    newBottom = screen(2) + screen(4) - topMargin - newH;
    newBottom = max(screen(2) + bottomMargin, newBottom);

    set(hFig, 'Position', [newLeft, newBottom, newW, newH]);
end

function applyPaperFigureTweaks(hFig, pdfName)
% Keep the manually edited .fig layout as the source of truth.
% Only apply deterministic text/interpreter fixes here.

    switch pdfName
        case 'fig3_3_mode_time_mass.pdf'
            setAllInterpreters(hFig, 'latex');

        case {'fig3_4a_elements_aei.pdf', 'fig3_4b_elements_angles.pdf'}
            removeBackgroundFromLegends(hFig);

        case {'fig3_9_mass_gain_boundary.pdf', 'fig3_10_threshold_curves.pdf'}
            setRatioAxisSubscriptsUpright(hFig);
    end
end

function setAllInterpreters(hFig, interpreterName)
% Set LaTeX interpreter for text objects, legends, colorbars and tick labels.

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
function removeBackgroundFromLegends(hFig)
% The source figures keep the user-edited legend positions. This function
% only removes the word "background" from legend labels.

    legs = findall(hFig, 'Type', 'legend');
    if isempty(legs)
        legs = findall(hFig, 'Tag', 'legend');
    end

    for iLeg = 1:numel(legs)
        try
            labels = get(legs(iLeg), 'String');
            labels = replaceLabelText(labels, 'background', '');
            labels = replaceLabelText(labels, 'Background', '');
            labels = cleanupLabelWhitespace(labels);
            set(legs(iLeg), 'String', labels);
        catch
        end
    end
end

function setRatioAxisSubscriptsUpright(hFig)
% Convert r_T and r_I in axis labels to LaTeX roman subscripts.

    axs = findall(hFig, 'Type', 'axes');
    for iAx = 1:numel(axs)
        labels = [get(axs(iAx), 'XLabel'), get(axs(iAx), 'YLabel'), get(axs(iAx), 'ZLabel')];
        for iLabel = 1:numel(labels)
            try
                txt = get(labels(iLabel), 'String');
                txt = fixRatioSubscriptText(txt);
                set(labels(iLabel), 'String', txt, 'Interpreter', 'latex');
            catch
            end
        end
        try
            set(axs(iAx), 'TickLabelInterpreter', 'latex');
        catch
        end
    end
end

function out = fixRatioSubscriptText(in)
    if iscell(in)
        out = cellfun(@fixRatioSubscriptText, in, 'UniformOutput', false);
        return;
    end
    if isstring(in)
        out = arrayfun(@(x) string(fixRatioSubscriptText(char(x))), in);
        return;
    end
    out = char(in);
    out = regexprep(out, 'r_\\mathrm\{T\}', 'r_{\mathrm{T}}');
    out = regexprep(out, 'r_\\mathrm\{I\}', 'r_{\mathrm{I}}');
    out = regexprep(out, 'r_\{?T\}?', 'r_{\mathrm{T}}');
    out = regexprep(out, 'r_\{?I\}?', 'r_{\mathrm{I}}');
    out = regexprep(out, 'r_\{\\mathit\{T\}\}', 'r_{\mathrm{T}}');
    out = regexprep(out, 'r_\{\\mathit\{I\}\}', 'r_{\mathrm{I}}');
end

function out = replaceLabelText(in, oldText, newText)
    if iscell(in)
        out = cellfun(@(x) replaceLabelText(x, oldText, newText), in, 'UniformOutput', false);
    elseif isstring(in)
        out = replace(in, oldText, newText);
    else
        out = strrep(char(in), oldText, newText);
    end
end

function out = cleanupLabelWhitespace(in)
    if iscell(in)
        out = cellfun(@cleanupLabelWhitespace, in, 'UniformOutput', false);
    elseif isstring(in)
        out = strip(regexprep(in, '\s+', ' '));
    else
        out = strtrim(regexprep(char(in), '\s+', ' '));
    end
end
function exportPdfSameAsFigureSize(hFig, pdfPath)
% Export PDF with paper size identical to the displayed figure size.
% This avoids MATLAB's default A4 page and removes extra page margins.

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

    try
        print(hFig, pdfPath, '-dpdf', '-r300');
    catch ME
        warning('Default PDF export failed for %s. Retrying with OpenGL. Original error: %s', ...
            pdfPath, ME.message);
        print(hFig, pdfPath, '-dpdf', '-opengl', '-r300');
    end
end






