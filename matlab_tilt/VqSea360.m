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
h = 80;

%d = 258;
%h = 130;
ys =192-128;

mz = round(ys*d/(h-ys));
if (1) 
    for s = 0:29

    screen = zeros(256,256); % Y,X
        
    a = 2*pi/30*(s-15);
    RM = [cos(a) sin(a);-sin(a) cos(a)];
 
        for t = 0:2     % dovrei avere 30 angoli x 3 posizioni 

            for y = -128:0.5:min([192-128,(h-1)])
                z = d*y/(h-y);
                for x = -256:0.5:256
                    xp = x/d*(z+d);        
                    pp = [xp;z] + [s;t]*Lt/4;
                    p1  = round(RM* ([192-y;1+128+x]-[128;128]))+[128;128];
                    if ((p1(1)>0) && (p1(1)<=256) && (p1(2)>0) && (p1(2)<=256)) 
                        screen(p1(1),p1(2)) = texture(floor(1+mod(pp(1),Ls-1)),floor(1+mod(pp(2),Lt-1)));
                    end
                end
            end
            image(uint8(screen));
            colormap([1 1 1; 0 0 0.5;]);
            axis equal;
            pause(0.01);

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
        % Rows of X correspond to points
		[IDX, C] = kmeans(X, 256, 'Distance','cityblock','OnlinePhase','on','Replicates',50); 
		% Arrange columns of Y
		Y = C(IDX,:)';
        R = col2im(Y,[8 8], [256*6 64],'distinct')';
        H = [H; uint8(R>0.5)];            % reconstructed image
        
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
    