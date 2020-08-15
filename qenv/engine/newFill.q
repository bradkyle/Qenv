

// select dst:qtyDist[last maxN;last numLvls;pleaves;poffset;shft;qty;rp] from lt
deriveTrades  :{[maxN;numLvls;leaves;offset;shft;qty;rp]
            dc:(maxN*2)+1; 
            tdc:til[dc];
            d:(numLvls,dc)#0; // empty matrix
            idx:(1+tdc) mod 2;
            aidx:-1_where[idx]; / idxs for agent sizes
            oidx:where[not[idx]]; / idxs for offsets
            d[;aidx]: leaves;
            d[;oidx]: offset;
            d[;dc-1]: Clip(qty-max'[shft]);
            sd:(d-Clip[sums'[flip raze (enlist(d[;0]-rp);flip d[;1_tdc])]])
            tqty:flip raze'[(sd*(sd>0) and (d>0))];

        };