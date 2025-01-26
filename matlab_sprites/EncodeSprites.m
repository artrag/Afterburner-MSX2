
function sprite_encode()

clear
close all

inp = 'NewAllSprites.bmp';
[I,MAP] = imread(inp);
name = 'new_sprt_data';

xi = 1;yi = 1;yf = 1;
old_yf = yf;

FrameNum = 0;
AllPat = [];
AllCol = [];

% process player

while (xi<=size(I,2) && yi+79<=size(I,1))

    x = xi;
    while (x<=size(I,2))
        A = I(yi:(yi+15),(x+(0:15)));   
        if (any(any(A)))
            x = x + 16;
        else
            break;
        end
    end
    xf = x-1;

    if (yf>old_yf)
        old_yf = yf;    % store in case we need to skip
    end
    
    y =  yi;
    while (y<=size(I,1))
        A = I(y+(0:15),xi:xf);
        if (any(any(A)))
            y = y + 16;
        else
            break;
        end    
    end
    yf = y-1;

    A = I(yi:yf,xi:xf);
    [pat,col,xoff,yoff,Nsprt] = convert_frame(A);

    if (Nsprt>0)
        image(uint8(A));
        axis equal;
        colormap(MAP);
        pause(0.01);
        FrameNum = FrameNum + 1;
    else
        sprintf('No frame at: %d,%d',xi,yi)
        yi = old_yf +17;
        xi = 1;
        continue;
    end
        
    n = FrameNum;
    
    np = size(AllPat,1);    % posizione corrente tabella pattern
    tstpat = np:(np+Nsprt-1);
    nc = size(AllCol,1);    % posizione corrente tabella colori
    tstcol = nc:(nc+Nsprt-1);

    sprite(n).Ns = Nsprt;
    sprite(n).dx = xoff;
    sprite(n).dy = yoff;
    sprite(n).pat = tstpat;
    sprite(n).col = tstcol;
    
    AllPat = [AllPat;pat];
    AllCol = [AllCol;col];
    
    if (xf<size(I,2))
        xi = xf+17;
    else
        yi = yf+17;
        xi = 1;
    end
end

FrameNum

inp = 'ExplosionsScaled.bmp';
[E,MAP] = imread(inp);

% process enemies
inp = 'MyEnemiesScaled1.bmp';
[I,MAP] = imread(inp);
inp = 'MyEnemiesScaled2.bmp';
[J,MAP] = imread(inp);
inp = 'MyEnemiesScaled3.bmp';
[K,MAP] = imread(inp);
inp = 'MyEnemiesScaled4.bmp';
[H,MAP] = imread(inp);
inp = 'MyEnemiesScaled5.bmp';
[P,MAP] = imread(inp);

I = [E;I;J;K;H;P];

BaseSize = size(I,2)/16;

for y=1:BaseSize:size(I,1)
    for x=1:BaseSize:size(I,2)
        A = I(y:(y+BaseSize-1),x:(x+BaseSize-1));
        [pat,col,xoff,yoff,Nsprt] = convert_frame(A);
        if (Nsprt>0)
            image(uint8(A));
            axis equal;
            colormap(MAP);
            pause(0.001);
            FrameNum = FrameNum + 1;
        else
            sprintf('No frame at: %d,%d',x,y)
            continue;
        end

        n = FrameNum;
        
        np = size(AllPat,1);    % posizione corrente tabella pattern
        tstpat = np:(np+Nsprt-1);
        nc = size(AllCol,1);    % posizione corrente tabella colori
        tstcol = nc:(nc+Nsprt-1);
        
        sprite(n).Ns = Nsprt;
        sprite(n).dx = xoff;
        sprite(n).dy = yoff;
        sprite(n).pat = tstpat;
        sprite(n).col = tstcol;

        AllPat = [AllPat;pat];
        AllCol = [AllCol;col];
      
    end
end
FrameNum
[size(AllPat,1),size(AllCol,1)]

[P,~,IP] = unique(AllPat,'rows','legacy');
AllPat = P;

[C,~,IC] = unique(AllCol,'rows','legacy');
AllCol = C;

[size(AllPat,1),size(AllCol,1)]

fid0 = fopen(['Spt_meta_' name '.h'],'wb');

for n=1:FrameNum
    Nsprt = sprite(n).Ns;
    xoff = sprite(n).dx;
    yoff = sprite(n).dy;
    tstpat = IP(sprite(n).pat+1)-1;
    tstcol = IC(sprite(n).col+1)-1;    
    
    fprintf(fid0,'// frame #%2d   ',n-1);fprintf(fid0,'  Nspr = %d \n',Nsprt);
    
    fprintf(fid0,'const unsigned char  FrmNs%d  = %d;    // # sprites in this frame \n',n-1,Nsprt);
    fprintf(fid0,'const unsigned char  Frmdx%d[]  = {',n-1);fprintf(fid0,'0x%2.2X,',xoff);fprintf(fid0,'};       // dx\n');
    fprintf(fid0,'const unsigned char  Frmdy%d[]  = {',n-1);fprintf(fid0,'0x%2.2X,',yoff);fprintf(fid0,'};       // dy\n');
    fprintf(fid0,'const unsigned int   FrmPat%d[] = {',n-1);fprintf(fid0,'0x%4.4X,',tstpat*2);fprintf(fid0,'}; // pat addresses (x2!)\n');
    fprintf(fid0,'const unsigned int   FrmCol%d[] = {',n-1);fprintf(fid0,'0x%4.4X,',tstcol);fprintf(fid0,'}; // col offsets\n');

end

fprintf(fid0,'\nunsigned char*  FrameAddr[] = {\n  ');
for n=1:FrameNum
    fprintf(fid0,'&FrmNs%d,',n-1);
end
fprintf(fid0,'\n}; // init data\n');

fclose(fid0);

fid0 = fopen(['Spt_meta_' name '.bin'],'wb');
for n=1:FrameNum
    Nsprt = sprite(n).Ns;
    xoff  = sprite(n).dx;
    yoff  = sprite(n).dy;
    tstpat = IP(sprite(n).pat+1)-1;
    tstcol = IC(sprite(n).col+1)-1;    
	
	fwrite(fid0,Nsprt,'uint8');
	fwrite(fid0,xoff ,'uint8');
	fwrite(fid0,yoff ,'uint8');
	fwrite(fid0,tstpat*2,'uint16');
	fwrite(fid0,tstcol,'uint16');
end
fclose(fid0);

fid0 = fopen(['Spt_offset_' name '.h'],'wb');
fprintf(fid0,'\n const unsigned char FrameOffset[] = {\n  ');
Offset = 0;
SegNum = 0;
for n=1:FrameNum
	Nsprt = sprite(n).Ns;
    fprintf(fid0,'	0x%2.2X,',bitand(Offset,255));
    fprintf(fid0,'0x%2.2X,',bitand(fix(Offset/256),63));
	fprintf(fid0,'0x%2.2X,\n',bitand(fix(Offset/16384),255));
	Offset = Offset + Nsprt*6 + 1;
    if (Offset>=16384) 
        SegNum = SegNum + 1;
    end
end
fprintf(fid0,'\n}; // init data\n');
disp(Offset );
fclose(fid0);

fid = fopen(['Spt_' name '.bin'],'wb');
fwrite(fid,AllPat','uint8');
fclose(fid);
fid = fopen(['Col_' name '.bin'],'wb');
fwrite(fid,AllCol','uint8');
fclose(fid);

disp(' Number of frames:');
FrameNum

end


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
    
    A = I(:,(x+(0:15)));
    [yy,~] = find(A>0);
    sminy = min(yy);
    
    for y=sminy:16:size(I,1)
        A = K((y+(0:15)),(x+(0:15)));
        if any(any(A))
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




function [c0,c1,s0,s1] = convert_sprite(A)

c0 = zeros(16,1);
c1 = zeros(16,1);
s0 = zeros(32,1);
s1 = zeros(32,1);

LL0 = [];
LL1 = [];

for y=1:16
    
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
    
    s0(y)    = binaryVectorToDecimal(L0(1:8),'MSBFirst');
    s0(y+16) = binaryVectorToDecimal(L0(9:16),'MSBFirst');
    s1(y)    = binaryVectorToDecimal(L1(1:8),'MSBFirst');
    s1(y+16) = binaryVectorToDecimal(L1(9:16),'MSBFirst');
    
    LL0 = [LL0;L0];
    LL1 = [LL1;L1];
end

if not(any(s1))
    s1=[];
    c1=[];
end
  

return
end




