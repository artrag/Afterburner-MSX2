
clear
close all

name = 'enmComp';
inp = 'compact_enemy_test.bmp';
[A,MAP] = imread(inp);

%[A,MAP] = imread(['rotated_sprites_' name '.bmp']);

L1 = bitor(A==3,A==1);
L2 = bitor(A==2,A==1);

figure;
image(A);
axis equal;
colormap(MAP);

S = [L1;L2];

figure;
imagesc(S);
axis equal;
colormap(gray);
imwrite(S*15,MAP,[ name '_layers.bmp']);

data = zeros(1,16*4*(size(A,2)/16-1));
ind = 1;

fid = fopen(['spt_' name '.bin'],'wb');
fid0 = fopen(['spt_' name '.h'],'w');

fprintf(fid0,['u8 ' name '_sprites[] = \n{\n']);

for f=0:(size(A,2)/16-1)
    S = L1;
    for n=1:16
        t = binaryVectorToDecimal(S(n,(1:8)+f*16),'MSBFirst');
        fwrite(fid,t,'uint8');
        fprintf(fid0,'0x%2.2X,',t);
        data(ind) = uint8(t);ind=ind+1;
    end
    for n=1:16
        t = binaryVectorToDecimal(S(n,(9:16)+f*16),'MSBFirst');
        fwrite(fid,t,'uint8');
        fprintf(fid0,'0x%2.2X,',t);
        data(ind) = uint8(t);ind=ind+1;
    end
    fprintf(fid0,'\n');
    for n=17:32
        t = binaryVectorToDecimal(S(n,(1:8)+f*16),'MSBFirst');
        fwrite(fid,t,'uint8');
        fprintf(fid0,'0x%2.2X,',t);
        data(ind) = uint8(t);ind=ind+1;
    end
    for n=17:32
        t = binaryVectorToDecimal(S(n,(9:16)+f*16),'MSBFirst');
        fwrite(fid,t,'uint8');
        fprintf(fid0,'0x%2.2X,',t);
        data(ind) = uint8(t);ind=ind+1;
    end
    fprintf(fid0,'\n');    

    S = L2;
    for n=1:16
        t = binaryVectorToDecimal(S(n,(1:8)+f*16),'MSBFirst');
        fwrite(fid,t,'uint8');
        fprintf(fid0,'0x%2.2X,',t);
        data(ind) = uint8(t);ind=ind+1;
    end
    for n=1:16
        t = binaryVectorToDecimal(S(n,(9:16)+f*16),'MSBFirst');
        fwrite(fid,t,'uint8');
        fprintf(fid0,'0x%2.2X,',t);
        data(ind) = uint8(t);ind=ind+1;
    end
    fprintf(fid0,'\n');
    for n=17:32
        t = binaryVectorToDecimal(S(n,(1:8)+f*16),'MSBFirst');
        fwrite(fid,t,'uint8');
        fprintf(fid0,'0x%2.2X,',t);
        data(ind) = uint8(t);ind=ind+1;
    end
    for n=17:32
        t = binaryVectorToDecimal(S(n,(9:16)+f*16),'MSBFirst');
        fwrite(fid,t,'uint8');
        fprintf(fid0,'0x%2.2X,',t);
        data(ind) = uint8(t);ind=ind+1;
    end
    fprintf(fid0,'\n');    
end

fprintf(fid0,'};\n');

fclose(fid);
fclose(fid0);

dim = size(data,2);
fid = fopen([name 'spt.bin'],'wb');
fwrite(fid,hex2dec(['FE';'00';'00';dec2hex([ round(mod(dim,256));round(dim/256)]);'00';'00']),'uint8');
fwrite(fid,data(1:end),'uint8');
fclose(fid);

% fid = fopen(['spt0_F14.bin'],'wb');
% fwrite(fid,hex2dec(['FE';'00';'00';'7F';'04';'00';'00']),'uint8');
% fwrite(fid,data(1:36*32),'uint8');
% fclose(fid);
% 
% fid = fopen(['spt1_F14.bin'],'wb');
% fwrite(fid,hex2dec(['FE';'00';'00';'7F';'04';'00';'00']),'uint8');
% fwrite(fid,data((36*32+1):(72*32)),'uint8');
% fclose(fid);
% 
% fid = fopen(['spt2_F14.bin'],'wb');
% fwrite(fid,hex2dec(['FE';'00';'00';'7F';'04';'00';'00']),'uint8');
% fwrite(fid,data((72*32+1):end),'uint8');
% fclose(fid);

%!copy *.bin             ..\data_bin
%return

