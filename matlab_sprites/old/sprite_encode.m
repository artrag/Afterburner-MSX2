
clear
close all

name = 'sprite_test';
inp = 'sprite_test.bmp';
[A,MAP] = imread(inp);

%[A,MAP] = imread(['rotated_sprites_' name '.bmp']);

L1 = bitor(A==15,A==8);
L2 = bitor(A==14,A==8);

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

fid = fopen(['spt_' name '.bin'],'wb');

fid0 = fopen(['spt_' name '.h'],'w');

fprintf(fid0,'u8 F14_sprites[] = \n{\n');


for f=0:(size(A,2)/16-1)
    for n=1:16
        t = binaryVectorToDecimal(S(n,(1:8)+f*16),'MSBFirst');
        fwrite(fid,t,'uint8');
        fprintf(fid0,'0x%2.2X,',t);
    end
    for n=1:16
        t = binaryVectorToDecimal(S(n,(9:16)+f*16),'MSBFirst');
        fwrite(fid,t,'uint8');
        fprintf(fid0,'0x%2.2X,',t);
    end
    fprintf(fid0,'\n');
    for n=17:32
        t = binaryVectorToDecimal(S(n,(1:8)+f*16),'MSBFirst');
        fwrite(fid,t,'uint8');
        fprintf(fid0,'0x%2.2X,',t);
    end
    for n=17:32
        t = binaryVectorToDecimal(S(n,(9:16)+f*16),'MSBFirst');
        fwrite(fid,t,'uint8');
        fprintf(fid0,'0x%2.2X,',t);
    end
    fprintf(fid0,'\n');    
end

fprintf(fid0,'};\n');

fclose(fid);
fclose(fid0);

%!copy *.bin             ..\data_bin
%return

