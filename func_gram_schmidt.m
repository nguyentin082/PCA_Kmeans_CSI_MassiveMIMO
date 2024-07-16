function U = func_gram_schmidt(V)
% The vectors v1,...,vk (columns of the matrix V) are replaced by the
% orthonormal vectors u1,...,uk (columns of the matrix U) which span the
% same subspace.

%ma trận đầu vào V thành các vector ortonôm U, 
% sao cho các vector này vẫn tạo thành không gian con tương tự.

%Vector đầu tiên của  U được thiết lập bằng việc chuẩn hóa vector đầu tiên của V.
%Với mỗi vector tiếp theo trong  V (từ cột thứ hai trở đi), nó sẽ được điều chỉnh 
% sao cho nó vuông góc với các vector đã xử lý trước đó trong U, tạo ra các vector ortonôm.

[n,k] = size(V);
U = zeros(n,k);
U(:,1) = V(:,1) / norm(V(:,1));

for i = 2:k
    U(:,i) = V(:,i);
    for j = 1:i-1
        U(:,i) = U(:,i) - (U(:,j)' * U(:,i)) / (norm(U(:,j)))^2 * U(:,j); % Điều chỉnh vector hiện tại trong U sao cho nó vuông góc với vector đã xử lý trước đó.
    end
    U(:,i) = U(:,i) / norm(U(:,i));
end
end