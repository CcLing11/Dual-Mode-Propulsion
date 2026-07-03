clear; clc;
figPath = 'E:\Grade2\双模小论文\IEEE_TAES_orig-research\figures_matlab\source_figs\fig3_3_mode_time_mass.fig';
pdfPath = 'E:\Grade2\双模小论文\IEEE_TAES_orig-research\figures_matlab\pdf_figures\fig3_3_mode_time_mass_updated.pdf';
hFig = openfig(figPath, 'new', 'visible');
set(hFig, 'Name', 'fig3_3_mode_time_mass_updated', 'NumberTitle', 'off');
drawnow;
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
close(hFig);
fprintf('Exported: %s\n', pdfPath);
