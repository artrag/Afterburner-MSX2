close all;
clear;

Lt = 64;
Ls = 96;


[org,map] = imread('..\graphics\texture.bmp');
texture = bitor(org(1:Ls,1:Lt)==0,org(1:Ls,1:Lt)==4) ;


% figure(50)
% image(uint8(texture))
% axis equal;
% colormap([1 1 1; 0 0 0.5;]);

d = 64;
h = 104;

%d = 258;
%h = 130;
%ys =192-128;

%mz = round(ys*d/(h-ys));
if (0) 
    for s = 0:29

    screen = zeros(256,256); % Y,X
        
    a = 2*pi/30*(s);
    RM = [cos(a) sin(a);-sin(a) cos(a)];
    b = -pi/16*sin(a);
    RT = [cos(b) sin(b);-sin(b) cos(b)];
    
        for t = 0:2     % dovrei avere 30 angoli x 3 posizioni 

            for xp=0:255
                for yp=0:255
                    q = RM * ([xp;yp]-[128;128])+[128;128];
                    ypp = q(2);
                    xpp = q(1);
                    if (ypp<h)
                        z = d*h/(h-ypp);
                        x = xpp*h/(h-ypp);
                        p = (RT * ([x;z]-[128;128]))+[128;128];
                        x = p(1);
                        z = p(2)+t*Lt/3;
                        if ((round(xp)<256)&&(round(xp)>=0)&&(round(yp)<256)&&(round(yp)>=0))
                            screen(round(yp)+1,round(xp)+1) = texture(floor(1+mod(x,Ls-1)),floor(1+mod(z,Lt-1)));
                        end
                    end
                end
            end
            
            image((uint8(screen)));
            colormap([1 1 1; 0 0 0.5;]);
            axis equal;
            pause (0.1);
            
 
             FILENAME = ['vq_sea' num2str(s) '_' num2str(t) '.bmp'];
             imwrite(uint8(screen),[1 1 1; 0 0 0.5;],FILENAME,'bmp');

        end
    end  
end



for s = 0:14 		%% merge frames with equal or opposite angle
    disp(s);
    K = [];
    for f=0:2
        FILENAME = ['vq_sea' num2str(s) '_' num2str(f) '.bmp'];
        [A,MAP] = imread(FILENAME);
        K = [K A];
    end
    for f=0:2        
        FILENAME = ['vq_sea' num2str(s+15) '_' num2str(f) '.bmp'];
        [A,MAP] = imread(FILENAME);
        K = [K A];
    end
    
    K = uint8(K);
    
    H  = [];
    T  = [];
    NT = [];
    for i=0:3							% 4 tile banks
        D = K((i*64+(1:64)),:);
        B = im2col(D',[8 8],'distinct');% D is processed by columns, thus it has to be transposed to work on rows
        X = double(B');					% 8x8 blocks in B are stored per column, so it has to be transposed to work on rows
        CC = unique(X,'rows');
        disp(size(CC,1))
        
        % Rows of X correspond to points
		[IDX, C] = kmeans(X, 240, 'Distance','cityblock','OnlinePhase','on','Replicates',50); 
		% Arrange columns of Y
		Y = C(IDX,:)';
        R = col2im(Y,[8 8], [256*6 64],'distinct')';
        H = [H; uint8(R>0.5)];            % reconstructed image

        C = [C; zeros(16,64)];        
        R = col2im(C',[8 8], [256 64],'distinct')';
        T = [T; uint8(R>0.5)];          % tileset
        
        R = reshape(IDX,6*32,8)';       % pattern numbers
        NT = [NT; uint8(R-1)];
    end
    
	figure;    
	image(H);
	colormap(MAP);
	axis equal;
	
    figure;    
    image(T);
    colormap(MAP);
    axis equal;
%     pause;
    
    figure;
    imagesc(NT);
    axis equal;
%     pause;

    name1 = ['..\data\vqtileset', num2str(s,'%2.2d'), '.bin'];
    fid1 = fopen(name1,'wb');

    for y=0:8:255
        for x=0:8:255
            u = T((y+1):(y+8),(x+1):(x+8));
            for i=1:8
                p = binaryVectorToDecimal(u(i,:)==0);
                fwrite(fid1,p,'uint8');                    
            end
        end
    end
    fclose(fid1);        
    
    pause(0.1);    

    name1 = ['..\data\vqnmtab',num2str(s,'%2.2d'),'_6p', '.bin'];
    fid1 = fopen(name1,'wb');
    for x=0:32:(size(NT,2)-1)
        p = NT(:,x+(1:32))';
        fwrite(fid1,p,'uint8');
    end
    fclose(fid1);        
    
end

name1 = ['..\data\vqtileset', num2str(0,'%2.2d'), '.bin'];
fid1 = fopen(name1,'rb');
T = fread(fid1);
T((1+(256+240)*8):(512*8))= bitxor(255,hex2dec([    '00';'10';'28';'28';'28';'10';'00';'00'
                                                    '00';'10';'30';'10';'10';'38';'00';'00'
                                                    '00';'10';'28';'08';'10';'38';'00';'00'
                                                    '00';'30';'08';'10';'08';'30';'00';'00'
                                                    '00';'20';'20';'38';'10';'10';'00';'00'
                                                    '00';'38';'20';'30';'08';'30';'00';'00'
                                                    '00';'18';'20';'38';'28';'10';'00';'00'
                                                    '00';'38';'08';'10';'20';'20';'00';'00'
                                                    '00';'10';'28';'10';'28';'10';'00';'00'
                                                    '00';'18';'28';'38';'08';'30';'00';'00'
                                                    '00';'10';'28';'38';'28';'28';'00';'00'
                                                    '00';'30';'28';'30';'28';'30';'00';'00'
                                                    '00';'10';'28';'20';'28';'10';'00';'00'
                                                    '00';'30';'28';'28';'28';'30';'00';'00'
                                                    '00';'38';'20';'30';'20';'38';'00';'00'
                                                    '00';'38';'20';'30';'20';'20';'00';'00']));
fclose (fid1);

fid1 = fopen(name1,'wb');
fwrite(fid1,T,'uint8');                    
fclose (fid1);

imagesc(reshape(T,[32, 32*8])');axis equal;

% s = 0;
% name1 = ['..\data\vqnmtab',num2str(s,'%2.2d'),'_6p', '.bin'];
% fid1 = fopen(name1,'rb');
% T = fread(fid1);
% fclose (fid1);
% T = reshape(T,[32 6*32])';
% 
% T(169,:) = 0;
% imagesc(T);axis equal;
% 
% fid1 = fopen(name1,'wb');
% fwrite(fid1,T','uint8');                    
% fclose (fid1);
