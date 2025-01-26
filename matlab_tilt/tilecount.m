figure
% 
% name0 = 'C:\Users\PC\OneDrive\Documenti\MSXgl-1.0.0\projects\AfterBurner\graphics\SeaJP\frame_';
% name1 = '_delay-0.1s.gif';
% 
% for a=0:3
%     [A,MAP] = imread([name0 num2str(a) name1 ]);
%     B = uint8(zeros(256));
%     B(1:size(A,1),1:size(A,2)) = A;
%     image(B);
%     colormap(MAP);
%     axis equal;
%     pause;
%     p = [];
%     for i=0:3
%         C = B((i*64+(1:63)),:);
%         D = im2col(C,[8 8],'distinct');
%         E = unique(D','rows');
%         p = [ p size(E,1)];
%     end
%     p
%     
% end

%return

for a=0:4
    K = [];
    for f=0:2
        [A,MAP] = imread(['sea' num2str(a) '_' num2str(f) '.bmp' ]);
        image(A);
        colormap(MAP);
        axis equal;
        pause(0.1);
        K = [K A];
    end
    p = [];
    for i=0:3
        D = K((i*64+(1:63)),:);
        B = im2col(D,[8 8],'distinct');
        C = unique(B','rows');
        p = [ p size(C,1)];
    end
    p

end
    
