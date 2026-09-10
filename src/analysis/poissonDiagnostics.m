function R = poissonDiagnostics(x, fs, threshold, doPlot)
%POISSONDIAGNOSTICS  Test whether a sparse counting/amplitude record is Poisson.
%
%   R = poissonDiagnostics(X, FS)
%   R = poissonDiagnostics(X, FS, THRESHOLD)
%   R = poissonDiagnostics(X, FS, THRESHOLD, DOPLOT)
%
%   X          vector of samples (e.g. 8-bit ADC values, mostly zero)
%   FS         sampling rate in Hz
%   THRESHOLD  a sample counts as an event if X > THRESHOLD (default 0)
%   DOPLOT     true to draw diagnostic figures (default true)
%
%   Returns struct R with all computed statistics.
%
%   The function separates the two questions that "is it Poisson?" conflates:
%     (A) Is the marginal distribution of the raw values Poisson?
%     (B) Is the underlying EVENT ARRIVAL PROCESS a homogeneous Poisson process?
%   For pulse-amplitude data (A) will always fail; (B) is the meaningful test.
%
%   No toolboxes required -- all distribution functions are implemented locally.

if nargin < 3 || isempty(threshold), threshold = 0;   end
if nargin < 4 || isempty(doPlot),    doPlot    = true; end

x = double(x(:));
N = numel(x);
R = struct();
R.n = N;
R.fs = fs;
R.duration_s = N/fs;
R.threshold = threshold;

fprintf('\n===============================================================\n');
fprintf(' POISSON DIAGNOSTICS\n');
fprintf('===============================================================\n');
fprintf('n = %d samples, fs = %.4g Hz, duration = %.1f s\n', N, fs, R.duration_s);

%% ---------------------------------------------------------------
%  (A) Marginal distribution of the RAW values
%  ---------------------------------------------------------------
R.mean = mean(x);
R.var  = var(x);            % MATLAB var() uses 1/(n-1) by default
R.fano = R.var / R.mean;
R.zeroFrac = mean(x == 0);
R.poissonP0 = exp(-R.mean);

% Index-of-dispersion test: (n-1)*s^2/xbar ~ chi2(n-1) under Poisson
R.dispersion.chi2 = (N-1) * R.var / R.mean;
R.dispersion.df   = N - 1;
R.dispersion.p    = chi2upper(R.dispersion.chi2, R.dispersion.df);
R.dispersion.z    = (R.dispersion.chi2 - R.dispersion.df) / sqrt(2*R.dispersion.df);

fprintf('\n--- (A) RAW VALUES ---------------------------------------------\n');
fprintf('mean = %.4f   var = %.2f   max = %d\n', R.mean, R.var, max(x));
fprintf('Fano (var/mean) = %.2f            [Poisson: 1]\n', R.fano);
fprintf('zero fraction   = %.4f            [Poisson predicts %.3e]\n', ...
        R.zeroFrac, R.poissonP0);
fprintf('dispersion test : chi2 = %.0f on %d df, z = %.1f, p = %.3g\n', ...
        R.dispersion.chi2, R.dispersion.df, R.dispersion.z, R.dispersion.p);
if R.fano > 3
    fprintf('  -> strongly overdispersed. Values are almost certainly\n');
    fprintf('     AMPLITUDES, not counts. Proceed to (B).\n');
end

%% ---------------------------------------------------------------
%  Fano vs bin size -- flat means stationary rate, rising means drift
%  ---------------------------------------------------------------
ks = [1 2 5 10 25 50 100];
ks = ks(ks <= floor(N/10));            % need >=10 bins to be meaningful
R.fanoVsBin.k = ks;
R.fanoVsBin.fano = zeros(size(ks));
fprintf('\n--- Fano vs bin size (flat = stationary rate) -------------------\n');
fprintf('%6s %10s %12s %8s\n', 'k', 'mean', 'var', 'Fano');
for i = 1:numel(ks)
    k = ks(i);
    y = rebin(x, k);
    R.fanoVsBin.fano(i) = var(y)/mean(y);
    fprintf('%6d %10.2f %12.1f %8.2f\n', k, mean(y), var(y), R.fanoVsBin.fano(i));
end
% log-log slope: ~0 for stationary Poisson-rate, ~1 for a drifting (Cox) rate
if numel(ks) >= 3
    pfit = polyfit(log(ks(:)), log(R.fanoVsBin.fano(:)), 1);
    R.fanoVsBin.logSlope = pfit(1);
    fprintf('log-log slope = %+.2f   [0 = stationary, ~1 = drifting rate]\n', pfit(1));
end

%% ---------------------------------------------------------------
%  (B) THE EVENT TRAIN -- this is the test that matters
%  ---------------------------------------------------------------
b   = double(x > threshold);
idx = find(b);
nEv = numel(idx);
R.events.n = nEv;
R.events.rate_Hz = nEv/N*fs;

fprintf('\n--- (B) EVENT TRAIN (x > %g) -----------------------------------\n', threshold);
fprintf('%d events in %.1f s  ->  rate = %.3f Hz\n', nEv, R.duration_s, R.events.rate_Hz);

% -- B1: counts per window vs Poisson, chi-square goodness of fit
win = max(1, round(fs));                       % ~1 second windows
y   = rebin(b, win);
lam = mean(y);
R.events.window = win;
R.events.lambdaPerWindow = lam;
R.events.fanoCounts = var(y)/mean(y);
[c2, df, p] = poissonGOF(y, lam);
R.events.gof.chi2 = c2; R.events.gof.df = df; R.events.gof.p = p;
fprintf('counts per %d-sample (%.2f s) window: mean = %.2f, Fano = %.2f\n', ...
        win, win/fs, lam, R.events.fanoCounts);
fprintf('  Poisson chi2 GOF: chi2 = %.2f, df = %d, p = %.3f %s\n', ...
        c2, df, p, verdict(p));

% -- B2: inter-event gaps vs geometric (discrete-time exponential)
g = diff(idx);
R.gaps.mean = mean(g);
R.gaps.var  = var(g);
R.gaps.varPredicted = mean(g)^2 - mean(g);      % geometric on {1,2,...}
[c2g, dfg, pg] = geometricGOF(g);
R.gaps.gof.chi2 = c2g; R.gaps.gof.df = dfg; R.gaps.gof.p = pg;
fprintf('inter-event gaps: mean = %.2f, var = %.2f  [geometric predicts %.2f]\n', ...
        R.gaps.mean, R.gaps.var, R.gaps.varPredicted);
fprintf('  geometric chi2 GOF: chi2 = %.2f, df = %d, p = %.3f %s\n', ...
        c2g, dfg, pg, verdict(pg));

% -- B3: runs test on the binary occupancy series (clustering?)
[z, nRuns, expRuns, sdRuns] = runsTest(b);
R.runs.observed = nRuns; R.runs.expected = expRuns; R.runs.z = z;
R.runs.p = 2*(1 - normupperToP(abs(z)));
fprintf('runs test: %d runs vs %.0f +/- %.1f expected, z = %+.2f, p = %.3f %s\n', ...
        nRuns, expRuns, sdRuns, z, R.runs.p, verdict(R.runs.p));

% -- B4: lag-1 autocorrelation
R.acf1.counts = corrcoefScalar(x(1:end-1), x(2:end));
R.acf1.onoff  = corrcoefScalar(b(1:end-1), b(2:end));
fprintf('lag-1 autocorr: counts = %+.3f, on/off = %+.3f  [Poisson: 0]\n', ...
        R.acf1.counts, R.acf1.onoff);

% -- B5: rate homogeneity across segments
nSeg = 6;
edges = round(linspace(0, N, nSeg+1));
cnt = zeros(1,nSeg); len = zeros(1,nSeg);
for i = 1:nSeg
    seg = b(edges(i)+1:edges(i+1));
    cnt(i) = sum(seg); len(i) = numel(seg);
end
expc = sum(cnt) * len / sum(len);
c2h  = sum((cnt-expc).^2 ./ expc);
ph   = chi2upper(c2h, nSeg-1);
R.homogeneity.counts = cnt;
R.homogeneity.chi2 = c2h; R.homogeneity.df = nSeg-1; R.homogeneity.p = ph;
fprintf('rate homogeneity over %d segments: counts = [%s]\n', nSeg, num2str(cnt));
fprintf('  chi2 = %.2f, df = %d, p = %.3f %s\n', c2h, nSeg-1, ph, verdict(ph));

%% ---------------------------------------------------------------
%  (C) AMPLITUDE DISTRIBUTION of the events
%  ---------------------------------------------------------------
a = x(idx);
R.amp.n = numel(a);
R.amp.mean = mean(a);
R.amp.sd = std(a);
R.amp.cv = std(a)/mean(a);
R.amp.median = median(a);
R.amp.skew = mean(((a-mean(a))/std(a)).^3);
R.amp.gammaShape = gammaShapeMLE(a);

fprintf('\n--- (C) EVENT AMPLITUDES ---------------------------------------\n');
fprintf('n = %d  mean = %.1f  sd = %.1f  median = %.0f\n', ...
        R.amp.n, R.amp.mean, R.amp.sd, R.amp.median);
fprintf('CV   = %.2f   [exponential: 1.00]\n', R.amp.cv);
fprintf('skew = %.2f   [exponential: 2.00]\n', R.amp.skew);
fprintf('gamma shape (MLE) k = %.2f   [k = 1 is exponential]\n', R.amp.gammaShape);

% Low-end comparison against exponential -- catches threshold artefacts
nLow = 10;
obsLow = zeros(1,nLow); expLow = zeros(1,nLow);
for v = 1:nLow
    obsLow(v) = sum(a == v);
    expLow(v) = R.amp.n * (exp(-(v-1)/R.amp.mean) - exp(-v/R.amp.mean));
end
R.amp.lowObserved = obsLow; R.amp.lowExpected = expLow;
fprintf('low-end counts  (value 1..%d): %s\n', nLow, num2str(obsLow));
fprintf('exponential pred.            : %s\n', num2str(round(expLow)));
if obsLow(1) > 1.5*expLow(1)
    fprintf('  -> excess at small amplitudes: possible noise crossings,\n');
    fprintf('     dark counts, afterpulses, or rounding pile-up.\n');
end

%% ---------------------------------------------------------------
%  Summary verdict
%  ---------------------------------------------------------------
fprintf('\n--- SUMMARY ----------------------------------------------------\n');
if R.fano > 3
    fprintf('Raw values      : NOT Poisson (Fano = %.1f) -- treat as amplitudes.\n', R.fano);
end
pAll = [R.events.gof.p, R.runs.p, R.homogeneity.p];
if all(pAll > 0.05)
    fprintf('Arrival process : consistent with a HOMOGENEOUS POISSON process\n');
    fprintf('                  at %.2f Hz. Use sqrt(N) on event counts.\n', R.events.rate_Hz);
else
    fprintf('Arrival process : deviates from homogeneous Poisson.\n');
    if R.homogeneity.p < 0.05
        fprintf('                  Rate is non-stationary (drift) -- fix this first.\n');
    end
    if R.runs.p < 0.05
        fprintf('                  Events are temporally clustered.\n');
    end
end
fprintf('================================================================\n\n');

%% ---------------------------------------------------------------
%  Plots
%  ---------------------------------------------------------------
if doPlot
    figure('Name','Poisson diagnostics','Color','w');

    subplot(2,3,1);
    plot((0:N-1)/fs, x, 'k-'); xlabel('time (s)'); ylabel('value');
    title(sprintf('Record (%.0f%% zeros)', 100*R.zeroFrac)); axis tight;

    subplot(2,3,2);
    loglog(R.fanoVsBin.k, R.fanoVsBin.fano, 'o-','LineWidth',1.2); hold on;
    yline(1,'r--'); xlabel('bin size k'); ylabel('Fano');
    title('Fano vs bin size'); grid on;

    subplot(2,3,3);
    vmax = max(y);
    hc = histcounts(y, -0.5:1:(vmax+0.5));
    kk = 0:vmax;
    bar(kk, hc/sum(hc), 'FaceColor',[.7 .7 .8]); hold on;
    plot(kk, poisspmfLocal(kk, lam), 'r.-','LineWidth',1.4,'MarkerSize',14);
    xlabel(sprintf('events per %.2f s', win/fs)); ylabel('probability');
    title(sprintf('Counts vs Poisson (p=%.2f)', p)); legend('observed','Poisson');

    subplot(2,3,4);
    hg = histcounts(g, 0.5:1:(max(g)+0.5));
    gv = 1:max(g);
    bar(gv, hg/sum(hg), 'FaceColor',[.7 .8 .7]); hold on;
    pg_ = 1/mean(g);
    plot(gv, (1-pg_).^(gv-1)*pg_, 'r-','LineWidth',1.4);
    xlabel('gap (samples)'); ylabel('probability');
    title(sprintf('Gaps vs geometric (p=%.2f)', pg)); legend('observed','geometric');

    subplot(2,3,5);
    edgesA = linspace(0, max(a), 25);
    ha = histcounts(a, edgesA); ctr = (edgesA(1:end-1)+edgesA(2:end))/2;
    bar(ctr, ha/sum(ha)/mean(diff(edgesA)), 'FaceColor',[.8 .7 .7]); hold on;
    plot(ctr, exp(-ctr/R.amp.mean)/R.amp.mean, 'r-','LineWidth',1.4);
    xlabel('amplitude'); ylabel('density');
    title(sprintf('Amplitudes (CV=%.2f)', R.amp.cv)); legend('observed','exponential');

    subplot(2,3,6);
    bar(1:nSeg, cnt, 'FaceColor',[.7 .7 .7]); hold on;
    plot(1:nSeg, expc, 'r--o','LineWidth',1.2);
    xlabel('segment'); ylabel('event count');
    title(sprintf('Rate stationarity (p=%.2f)', ph));
end
end

%% ================= local helper functions ==========================

function y = rebin(x, k)
% Sum non-overlapping blocks of k samples.
m = floor(numel(x)/k)*k;
y = sum(reshape(x(1:m), k, []), 1)';
end

function p = poisspmfLocal(k, lam)
% Poisson pmf without the Statistics Toolbox.
p = exp(-lam + k.*log(lam) - gammaln(k+1));
end

function p = chi2upper(xv, df)
% Upper-tail chi-square probability, base MATLAB only.
p = gammainc(xv/2, df/2, 'upper');
end

function P = normupperToP(z)
% Standard normal CDF, base MATLAB only.
P = 0.5*erfc(-z/sqrt(2));
end

function r = corrcoefScalar(u, v)
c = corrcoef(u, v);
r = c(1,2);
end

function s = verdict(p)
if p < 0.01
    s = '** REJECT';
elseif p < 0.05
    s = '*  reject at 0.05';
else
    s = '   consistent';
end
end

function [z, nRuns, expRuns, sdRuns] = runsTest(b)
% Wald-Wolfowitz runs test on a binary series. Negative z = clustering.
n  = numel(b);
n1 = sum(b == 1);
n0 = n - n1;
nRuns   = 1 + sum(diff(b) ~= 0);
expRuns = 2*n1*n0/n + 1;
sdRuns  = sqrt(2*n1*n0*(2*n1*n0 - n) / (n^2*(n-1)));
z = (nRuns - expRuns) / sdRuns;
end

function [c2, df, p] = poissonGOF(y, lam)
% Chi-square goodness of fit of counts Y against Poisson(LAM),
% pooling adjacent bins until expected >= 5.
n = numel(y);
vmax = max(y);
kk = (0:vmax)';
obs = zeros(size(kk));
for i = 1:numel(kk), obs(i) = sum(y == kk(i)); end
expc = poisspmfLocal(kk, lam)*n;
expc(end) = expc(end) + n*(1 - sum(poisspmfLocal((0:vmax)', lam)));  % tail
[o, e] = poolBins(obs, expc);
c2 = sum((o-e).^2 ./ e);
df = numel(o) - 1 - 1;      % -1 for total, -1 for estimated lambda
df = max(df, 1);
p = chi2upper(c2, df);
end

function [c2, df, p] = geometricGOF(g)
% Chi-square goodness of fit of gaps G against a geometric on {1,2,...}.
n = numel(g);
ph = 1/mean(g);
gmax = max(g);
gv = (1:gmax)';
obs = zeros(size(gv));
for i = 1:numel(gv), obs(i) = sum(g == gv(i)); end
expc = (1-ph).^(gv-1) * ph * n;
expc(end) = expc(end) + n*(1-ph)^gmax;   % remaining tail
[o, e] = poolBins(obs, expc);
c2 = sum((o-e).^2 ./ e);
df = max(numel(o) - 2, 1);   % -1 total, -1 estimated p
p = chi2upper(c2, df);
end

function [o, e] = poolBins(obs, expc)
% Merge adjacent bins until every expected count is at least 5.
o = []; e = [];
co = 0; ce = 0;
for i = 1:numel(obs)
    co = co + obs(i); ce = ce + expc(i);
    if ce >= 5
        o(end+1,1) = co; e(end+1,1) = ce; %#ok<AGROW>
        co = 0; ce = 0;
    end
end
if ce > 0
    if isempty(o)
        o = co; e = ce;
    else
        o(end) = o(end) + co; e(end) = e(end) + ce;
    end
end
end

function k = gammaShapeMLE(a)
% MLE of gamma shape by Newton iteration on  log(k) - psi(k) = s.
a = a(a > 0);
s = log(mean(a)) - mean(log(a));
k = (3 - s + sqrt((s-3)^2 + 24*s)) / (12*s);   % Minka's initial guess
for it = 1:100
    num = log(k) - psi(k) - s;
    den = 1/k - psi(1, k);
    knew = k - num/den;
    if knew <= 0, knew = k/2; end
    if abs(knew-k) < 1e-10, k = knew; break; end
    k = knew;
end
end
