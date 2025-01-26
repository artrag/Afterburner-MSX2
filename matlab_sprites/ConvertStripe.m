
function [c0,c1,s0l,s0r,s1l,s0r] = convert_stripe(A)
h = size(A,1);

c0 = zeros(h,1);
c1 = zeros(h,1);
s0l = zeros(h,1);
s0r = zeros(h,1);
s1l = zeros(h,1);
s1r = zeros(h,1);

for y=1:h
	t = A(y,1:16);
	c = unique(t);

    L0 = zeros(1,16);
    L1 = zeros(1,16);

    switch size(c,2)
        case 1
            if (c(1)>0) 
                c0(y) = c;                
                L0 = (t==c(1));
            end
        case 2
            if (c(1)==0)
                c0(y) = c(2);
                L0 = (t==c(2));
            else
                c0(y) = c(1);
                c1(y) = c(2);
                L0 = (t==c(1));                
                L1 = (t==c(2));                
            end
        case 3
            if (c(1)==0)
                c0(y) = c(2);
                c1(y) = c(3);
                L0 = (t==c(2));                
                L1 = (t==c(3));                
            else
                if (c(3)==bitor(c(1),c(2)))
                    c0(y) = c(1);
                    c1(y) = c(2) + 64;
                    L0 = bitor(t==c(1),t==c(3));                
                    L1 = bitor(t==c(2),t==c(3));                
                else
                    disp('ERROR: OR rule violated');
                    return
                end
            end
        case 4
            if (c(1)==0)
                if (c(4)==bitor(c(2),c(3)))
                    c0(y) = c(2);
                    c1(y) = c(3) + 64;
                    L0 = bitor(t==c(2),t==c(4));                
                    L1 = bitor(t==c(3),t==c(4));                
                else
                    disp('ERROR: OR rule violated');
                    return
                end
            else
                disp('ERROR: more than 3 colors');
                return
            end
        otherwise
            disp('ERROR: more than 3 colors');
            return
    end

    s0l(y) = binaryVectorToDecimal(L0(1:8),'MSBFirst');
    s0r(y) = binaryVectorToDecimal(L0(9:16),'MSBFirst');
    s1l(y) = binaryVectorToDecimal(L1(1:8),'MSBFirst');
    s1r(y) = binaryVectorToDecimal(L1(9:16),'MSBFirst');
    
    LL0 = [LL0;L0];
    LL1 = [LL1;L1];
	
end

if not(any(s1))
    s1=[];
    c1=[];
end
  
end
