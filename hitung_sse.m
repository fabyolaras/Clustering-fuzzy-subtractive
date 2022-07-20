function csse = hitung_sse (norm, cntr, clust)
C = norm{1,clust};
[n m] = size(C);
pC = (C-cntr(clust,:)).^2;
csse = sum(pC);