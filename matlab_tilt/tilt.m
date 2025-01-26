close all;

Lt = 64;
Ls = 96;
%i = 0:(Lt-1);
%j = 0:(Lt-1);

[org,map] = imread('..\graphics\texture.bmp');
texture = bitor(org(1:Ls,1:Lt)==0,org(1:Ls,1:Lt)==4) ;

[org,map] = imread('..\graphics\sky.bmp');
sky = uint8(org>0);
%texture = (sin(i/Lt*pi)'*sin(j/Lt*pi))<=0.3;

figure
image(uint8(texture))
axis equal;
colormap([1 1 1; 0 0 0.5;]);

figure
image(uint8(sky))
axis equal;
colormap([1 1 1; 0 0 0.5;]);


d = 128;
h = 156;

%d = 258;
%h = 130;
ys =192-63;

mz = round(ys*d/(h-ys))
    

for s = 0:4

    figure;
    screen = zeros(256,256); % Y,X
        
    a = 2*pi/30*(s-2);
    RM = [cos(a) sin(a);-sin(a) cos(a)];

%     for y = 1:256
%         for x = 1:256
%             p = round( RM^(-1)*[x-128;y-128])+[128; 128];
%             %if ((p(1)>0) && (p(1)<=256) && (p(2)>0) && (p(2)<=256)) 
%             p = mod(p,256)+1;
%             screen(x,y) = sky(p(1),p(2));
%             %end
%         end
%     end
%     
%     image(uint8(screen));
%     colormap([1 1 1; 0 0 0.5;]);
%     axis equal;
%         
%     drawnow;
    
    for t = 0:2     % (-3:7) dovrei avere 11 posizioni
        
%         for y = (h+1):256
%             z = d*y/(h-y);
%             for x = 1:256
%                 xp = x/d*(z+d);        
%                 pp = [xp;z] + [s;t]*Lt/4;
%                 p1  = round(RM* ([192-y;1+128+x]-[96;128]))+[96;128];
%                 p1 = mod(p1,256)+1;
%                 screen(p1(1),p1(2)) = texture(floor(1+mod(pp(1),Ls-1)),floor(1+mod(pp(2),Lt-1)));
%             end
%         end
                
        for y = -96:0.5:min([192-64,(h-1)])
            z = d*y/(h-y);
            for x = -256:0.5:256
                xp = x/d*(z+d);        
                pp = [xp;z] + [s;t]*Lt/4;
                p1  = round(RM* ([192-y;1+128+x]-[96;128]))+[96;128];
                if ((p1(1)>0) && (p1(1)<=256) && (p1(2)>0) && (p1(2)<=256)) 
                    screen(p1(1),p1(2)) = texture(floor(1+mod(pp(1),Ls-1)),floor(1+mod(pp(2),Lt-1)));
                end
            end
        end
        image(uint8(screen));
        colormap([1 1 1; 0 0 0.5;]);
        axis equal;
        
        drawnow;
        FILENAME = ['sea' num2str(s) '_' num2str(t) '.bmp'];
        imwrite(uint8(screen),[1 1 1; 0 0 0.5;],FILENAME,'bmp');
        pause(0.01);

        u = t+s*10;
        name0 = ['tstpat', sprintf('%2.2i',u), '.bin'];
        name1 = ['..\data\frmpat', sprintf('%2.2i',u), '.bin'];

        fid0 = fopen(name0,'wb');
        fid1 = fopen(name1,'wb');

        fwrite(fid0,hex2dec(['FE';'00';'00';'FF';'1F';'00';'00']),'uint8');
        
        for y=0:8:255
            for x=0:8:255
                u = screen((y+1):(y+8),(x+1):(x+8));
                for i=1:8
                    p = binaryVectorToDecimal(u(i,:)==0);
                    fwrite(fid0,p,'uint8');
                    fwrite(fid1,p,'uint8');                    
                end
            end
        end
        fclose(fid0);
        fclose(fid1);        
        
    end
end    

[org,map] = imread('..\graphics\tileset.bmp');
figure;
image(org);
colormap(map);


for x=1:8:8*8
    for y=1:2:8
        org(y+0,x:(x+7)) = decimalToBinaryVector(hex2dec('F0'),8);
        org(y+1,x:(x+7)) = decimalToBinaryVector(hex2dec('E0'),8);        
    end
end


fid0 = fopen('tileset.bin','wb');
fid1 = fopen('..\data\tiles.bin','wb');
fwrite(fid0,hex2dec(['FE';'00';'00';'FF';'07';'00';'00']),'uint8');

for y=0:8:63
    for x=0:8:255
        u = org((y+1):(y+8),(x+1):(x+8));
        for i=1:8
            p = binaryVectorToDecimal(u(i,:)>0.5);
            fwrite(fid0,p,'uint8');
            fwrite(fid1,p,'uint8');
        end
    end
end
fclose(fid0);
fclose(fid1);


fid0 = fopen('colors.bin','wb');
fwrite(fid0,hex2dec(['FE';'00';'00';'FF';'17';'00';'00']),'uint8');
for y=0:8:1024
    fwrite(fid0,hex2dec(['F4';'F4';'F4';'F4';'F4';'F4';'F4';'F4']),'uint8');
end
fclose(fid0);
