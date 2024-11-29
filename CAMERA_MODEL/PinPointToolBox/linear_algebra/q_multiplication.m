function qc = q_multiplication(qa, qb)

qc=zeros(4,1);

qc(1,1)= qb(4)*qa(1)+qb(3)*qa(2)-qb(2)*qa(3)+qb(1)*qa(4);
qc(2,1)=-qb(3)*qa(1)+qb(4)*qa(2)+qb(1)*qa(3)+qb(2)*qa(4);
qc(3,1)= qb(2)*qa(1)-qb(1)*qa(2)+qb(4)*qa(3)+qb(3)*qa(4);
qc(4,1)=-qb(1)*qa(1)-qb(2)*qa(2)-qb(3)*qa(3)+qb(4)*qa(4);

end