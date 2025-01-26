
function [pat,col,xoff,yoff,Nsprt] = convert_frame(I)

pat  = [];
col  = [];
xoff = [];
yoff = [];

% tutti i punti non nulli
[y,x] = find(I>0);
miny = min(y);
minx = min(x);

if (miny>1)
   J = [I(miny:end,:);I(1:(miny-1),:)]; 
   I = J;
end

if (minx>1)
   J = [I(:,minx:end),I(:,1:(minx-1))]; 
   I = J;
end

[y,x] = find(I>0);

by = round(mean(y));
bx = round(mean(x));

K = [I; zeros(16,size(I,2))];

Nsprt = 0;
for x=1:16:size(I,2)
    
    A = I(:,(x+(0:15))); 						% cut a stripe 64x16
	
	[c0,c1,s0l,s0r,s1l,s0r] = convert_stripe(A);
	
    [y0,~] = find(c0>0);
    sminy = min(y0);
    
    for y=sminy:16:size(A,1)
        A = s01(y+(0:15));
        if any(any(A))
			cc0 = c0(y+(0:15));
			s0  = [s0l(y+(0:15));s0r(y+(0:15));];
			
            [c0,c1,s0,s1] = convert_sprite(A);
            
            if (isempty(s1))
                Nsprt = Nsprt +1;                %saveonelayer(c0,s0,dx,dy);
                pat(Nsprt,:) = s0;
                col(Nsprt,:) = c0;
                xoff(Nsprt) = bitand(x - bx+256,255);
                yoff(Nsprt) = bitand(y - by+256,255);
         
            else
                Nsprt = Nsprt +1;                %saveonelayer(c0,s0,dx,dy);
                pat(Nsprt,:) = s0;
                col(Nsprt,:) = c0;
                xoff(Nsprt) = bitand(x - bx+256,255);
                yoff(Nsprt) = bitand(y - by+256,255);

                Nsprt = Nsprt +1;                %saveonelayer(c0,s0,dx,dy);
                pat(Nsprt,:) = s1;
                col(Nsprt,:) = c1;
                xoff(Nsprt) = bitand(x - bx+256,255);
                yoff(Nsprt) = bitand(y - by+256,255);
                
            end
                
        end
    end
end

end