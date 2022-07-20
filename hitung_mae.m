function cmae = hitung_mae (norm, cntr, clust)
C = norm{1,clust};
[n m] = size(C);
pC = abs(C-cntr(clust,:));
cmae = sum(pC)./(n);
