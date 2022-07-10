function outputForLatexLog(dataset, printHeader)
	% OUTPUTFORLATEXLOG
    %
    % History:
    %   12Jun2022 - SSP
    % ---------------------------------------------------------------------	

    if nargin < 2
        printHeader = true;
    end
    

    if printHeader
        expLabel = dataset.getLabel();
        expLabel = replace(expLabel, '_', '\_');
        fprintf('\\expheader{%s}\n', expLabel);
        fprintf('\t\\addcontentsline{toc}{subsection}{%s}\n', char(dataset.experimentDate));
    else
        fprintf('\t\\vspace{1ex}\n');
    end

    fprintf("\t\\begin{itemize}[noitemsep]\n");
    for i = 1:height(dataset.stim)
        fprintf('\t\t\\item %s \\reps{%u}\n', dataset.stim.Stimulus(i), dataset.stim.N(i));
    end
    fprintf('\t\\end{itemize}\n');

    % Footer
    fprintf('\t\\vspace{3ex}\n');
    fprintf('\t-------------------------------------------------\n');