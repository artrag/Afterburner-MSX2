
clear
close all

name = 'AllSprites';
inp = 'AllSprites.bmp';
[A,MAP] = imread(inp);

L1 = bitor(A==1,A==3);
L2 = bitor(A==2,A==3);

figure;
image(A);
axis equal;
colormap(MAP);

S = [L1;L2];
L = size(S)/16;

col =[zeros(size(L1)/16);ones(size(L2)/16)]; % colors

figure;
imagesc(S);
axis equal;
colormap(gray);
imwrite(S*15,MAP,[ name '_layers.bmp']);

V = im2col(S,[16 16],'distinct');
[C,ia,ic] = unique(V','rows');

dummy = (all(C(1,:)==0));

figure;
imagesc(col2im(C(ic,:)',[16 16],size(S),'distinct'));
axis equal;
colormap(gray);

D = C';
T = col2im(D,[16 16],[16 size(D,2)*16],'distinct');
figure;
imagesc(T);
axis equal;
colormap(gray);


pat = reshape(ic,L)-1;

pat2=[ pat(1:2:end,:); pat(2:2:end,:)];
pat = pat2;

col2=[ col(1:2:end,:); col(2:2:end,:)];
col = col2;

% deal with enemies
col(:,37:207)=col(:,37:207)*2;          % enemy planes
col(:,208:216) = col(:,208:216)*3;      % missiles
col(:,217:227) = col(:,217:227)*4;      % bullets
col(:,228:397) = col(:,228:397)*5;      % bullets
col(:,398:423) = col(:,398:423)*3;      % bullets

data = zeros(1,32*(size(T,2)/16));
ind = 1;

fid = fopen(['Spt_' name '.bin'],'wb');
fid0 = fopen(['Spt_' name '.h'],'w');

fprintf(fid0,'const unsigned char SprtPatDef[] = {\n');

for f=double(dummy):(size(T,2)/16-1)
    Q = T(:,(1:8)+f*16);
    for n=1:16
        t = binaryVectorToDecimal(Q(n,:),'MSBFirst');
        fwrite(fid,t,'uint8');
        fprintf(fid0,'0x%2.2X,',t);
        data(ind) = uint8(t);ind=ind+1;
    end
    Q = T(:,(9:16)+f*16);    
    for n=1:16
        t = binaryVectorToDecimal(Q(n,:),'MSBFirst');
        fwrite(fid,t,'uint8');
        fprintf(fid0,'0x%2.2X,',t);
        data(ind) = uint8(t);ind=ind+1;
    end
    fprintf(fid0,'\n');
end

fprintf(fid0,'};\n');

fclose(fid0);

fid0 = fopen(['Data_' name '.h'],'w');

ppp = [zeros(size(pat,1),1) pat];
s = find(all(ppp==0));

framestart = strfind(all(ppp==0),[1 0]);
frameend   = strfind(all(ppp==0),[0 1]);

by = [];
bx = [];
for n=1:size(framestart,2)

    x = [(framestart(n)-1)*16+1 (frameend(n)-1)*16];
    t = A(:,x(1):x(2))>0;
    [y,x] = find(t);
    by = [by round(mean(y))];
    bx = [bx round(mean(x))];
end


Nsprt = [];
for n=1:(size(framestart,2))

    dx = [];
    dy = [];
    pt = [];
    cl = [];

    for x=(framestart(n)+1):(frameend(n))
        for y=1:size(ppp,1)
            
            if (dummy) 
                if (ppp(y,x)>0) 
                    pt = [pt ppp(y,x)-1];
                    dx = [dx (x-framestart(n)-1)*16];
                    dy = [dy (floor((y-1)/2))*16];
                    cl = [cl col(y,x)];
                end 
            else
                pt = [pt ppp(y,x)];
                dx = [dx (x-framestart(n)-1)*16];
                dy = [dy (floor((y-1)/2))*16];
                cl = [cl col(y,x)];
            end            
        end
    end
    
    dx = bitand(dx - bx(n)+256,255);
    dy = bitand(dy - by(n)+256,255);
    Nsprt(n) = size(dx(:),1);
        
    fprintf(fid0,'// frame #%2d   ',n-1);
    fprintf(fid0,'  Nspr = %d \n',size(dx(:),1));
    fprintf(fid0,'const unsigned char  tstdx%d[] = {',n-1);fprintf(fid0,'0x%2.2X,',dx);fprintf(fid0,'}; // dx\n');
    fprintf(fid0,'const unsigned char  tstdy%d[] = {',n-1);fprintf(fid0,'0x%2.2X,',dy);fprintf(fid0,'}; // dy\n');
    fprintf(fid0,'const unsigned int   tstpat%d[] = {',n-1);fprintf(fid0,'0x%2.2X,',pt*32+16384);fprintf(fid0,'}; // pat addresses\n');
    fprintf(fid0,'const unsigned int   tstcol%d[] = {',n-1);fprintf(fid0,'0x%2.2X,',cl*16);fprintf(fid0,'}; // col offsets\n');
   
end

fprintf(fid0,'\nunsigned char*  SprtData[] = {\n');
for n=1:(size(framestart,2))
    fprintf(fid0,'	&tstdx%d[0], \n',n-1);
end
fprintf(fid0,'}; // init data\n');

fprintf(fid0,'\nunsigned char  SprtLen[] = {\n');
for n=1:(size(framestart,2))
    fprintf(fid0,'	%d,\n',Nsprt(n));
end
fprintf(fid0,'}; \n');


fclose(fid);
fclose(fid0);

disp(['Number of 16x16 sprite definitions: ',num2str(max(ppp(:)))]);

%copyfile(['spt_' name '.h'],'..\template_s254_b0.c');
%copyfile(['spt_' name '.h'],'..\template_s254_b1.c');
return
