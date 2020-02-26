# Viet chuong trinh cong, tru hai so thuc
.data
enterFirst: .asciiz "Enter the first number: "
enterSecond: .asciiz "\nEnter the second number: "
enterOperator: .asciiz "\nEnter operator (0. Addition, 1. Subtraction): "
printResult: .asciiz "\n Result: "
firstNumber: .word 0
secondNumber: .word 0
arrayTemp: .word 0
getFloatNumber: .word 0
error: .asciiz "\nNot found operator. Please enter again!!\nEnter operator (0. Addition, 1. Subtraction): " 



.text
main:
	la $a0,enterFirst
	li $v0,4
	syscall
	li $v0,6 # Nhap so thuc thu nhat
	syscall
	swc1 $f0,firstNumber # Luu so thuc thu nhat
	
	la $a0,enterSecond
	li $v0,4
	syscall
	li $v0,6 # Nhap so thuc thu hai
	syscall
	swc1 $f0,secondNumber # Luu so thuc thu hai
	
	la $a0,enterOperator
	li $v0,4
	syscall
# Nhap so de xác dinh toán tu se dùng. 0. Cong, 1. Tru. Neu nhap khac 0 hoac 1 thì se thông báo loi và cho nguoi dùng nh?p lai.
loop:	
	li $v0,5
	syscall
	beq $v0,0,endloop
	beq $v0,1,endloop
	
	la $a0,error
	li $v0,4
	syscall
	j loop
	
endloop:
	add $s0,$v0,$0 # Luu gia tri de xac dinh toán tu se dùng vào $s0
	
	
	lw $a0,firstNumber # Luy so thuc thu nhat luu vào $a0 (Dang HEX)
	lw $a1,secondNumber # Lay so thuc thu hai luu vào $a1 (Dang HEX)
	
	bne $s0,$0,Sub # Dua vào $s0 ta có the xac dinh duoc toan tu se dung
	jal Addition
	j End
# Ý tuong cua viec thuc hien phep tru dua trên viec doii dau toán hang thu 2 roi goi ham Addition. 
Sub:
	srl $t1,$a1,31 # Dau tiên ta can lay bit dau cua toan hang thu 2 de xac dinh no la 0 hay 1.
	beq $t1,$0,DoiDauSang1 # Neu no la 0 thi ta se chuyen no thanh 1.
	andi $a1,$a1,0x7fffffff # Neu no la 1 thi ta chuyen no thanh 0.
	j Subtraction
DoiDauSang1:
	ori $a1,$a1,0x80000000
	
Subtraction:
	jal Addition  # Sau khi dã doi dau toan hang thu hai thì ta goi ham cong de thuc thi.
	j End
	
End:
	la $s5,arrayTemp
	sw $v0,arrayTemp # Sau khi thuc thi xong thì ket qua duoc luu vào thanh ghi $v0, ta tien hành luu vào arrayTemp de duoc giá tri dang HEX.
	
	la $a0,printResult
	li $v0,4
	syscall
	
	lwc1 $f12,arrayTemp # Lay gia tri dang HEX luu vao bien $f12 thì ta se duoc so thuc tuong ung. Xuat ket qua và ket thuc chuong trinh.
	li $v0,2
	syscall
	
	li $v0,10
	syscall
# Bat dau ham Cong
Addition:
	addi $t0,$a0,0  # Lay so thuc (Dang HEX) tu $a0 dua vào $t0.
	addi $t1,$a1,0	# Lay so thuc (Dang HEX) tu $a1 dua vào $t1.
# Xu li truong hop 1 trong 2 toan hang nhap vao bang 0. Ta chi can xuat gia tri cua toan hang kia ra ngoai.
	beq $t0,0,ToanHang1Bang0
	beq $t1,0,ToanHang2Bang0
# Xu li truong hop tinh toan 2 so doi nhau lam cho ket qua bang 0
	la $s1,getFloatNumber
	sw $t0,0($s1)
	sw $t1,4($s1)
	lwc1 $f1,0($s1)
	lwc1 $f2,4($s1)
	abs.s $f1,$f1
	abs.s $f2,$f2
	c.eq.s $f1,$f2
	bc1f BoQuaTruongHopKetQuaBang0
	andi $t2,$t0,0x80000000
	andi $t3,$t1,0x80000000
	beq $t2,$t3,BoQuaTruongHopKetQuaBang0
	j XuatKetQuaBang0
	

BoQuaTruongHopKetQuaBang0:
# Dau tiên ta can xu lí bit dau. Ta cho lan luot $t0 và $t1 andi voi 0x80000000 de xac dinh duoc bit dau la 0 hay 1.
	andi $t2,$t0,0x80000000
	andi $t3,$t1,0x80000000
	
	beq $t2,0x80000000,checkSoAm
	j checkDau
checkSoAm:
	beq $t3,0x80000000,XuLi
	j checkDau
	
XuLi:
	addi $s4,$0,1
	j Next
checkDau:	
	bne $t2,$0,XuLiDau
	bne $t3,$0,XuLiDau
	addi $s4,$0,0  # Luu bit dau (1 bit)
	addi $a2,$0,0
	j Next
# O day ta lay dau nhu sau: Ta lay tri tuyet doi cua 2 so roi so sanh chung voi nhau. Neu so nào lon hon thi lay bit dau cua so do dua vao bit dau cua ket qua.
# Bit dau duoc luu vào thanh ghi $s4
XuLiDau:
	addi $a2,$0,1
	la $s1,getFloatNumber
	sw $t0,0($s1)
	sw $t1,4($s1)
	lwc1 $f1,0($s1)
	lwc1 $f2,4($s1)
	abs.s $f1,$f1
	abs.s $f2,$f2
	c.le.s $f1,$f2
	bc1t LayDauSoThuHai
	srl $t2,$t2,31
	add $s4,$0,$t2
	j Next
LayDauSoThuHai:
	srl $t3,$t3,31
	add $s4,$0,$t3
Next:	
	sll $t4,$t0,1
	sll $t5,$t1,1
	
	andi $t4,$t4,0xFFFFFFFF
	andi $t5,$t5,0xFFFFFFFF
	
	la $s1,arrayTemp
	sw $t4,0($s1)
	sw $t5,4($s1)
# Xu lí phan mu: Ta so sanh gia tri cua 2 phan mu voi nhau: 
#			+ Neu no bang nhau thi khong can xu lí. Ta chuyen sang xu lí phan dinh tri.
#			+ Neu no khong bang nhau thi ta cong hoac tru sao cho no bang nhau. Sau do can dich bit cua phan dinh tri de gia tri cua no khong thay doi. 
	lbu $t6,3($s1)  # Phan mu cua so thu nhat
	lbu $t7,7($s1)  # Phan mu cua so thu hai
	beq $t6,$t7,GiongMu
	
	slt $t8,$t6,$t7
	beq $t8,$0,MuSoThuNhatLonHon
	
	slt $t8,$t7,$t6
	beq $t8,$0,MuSoThuHaiLonHon
	
GiongMu:
	andi $t4,$t0,0x007fffff
	andi $t5,$t1,0x007fffff
	ori $t4,$t4,0x00800000
	ori $t5,$t5,0x00800000
	addi $t2,$t6,0
	j XuLiPhanThapPhan
	
MuSoThuNhatLonHon:
	sub $t8,$t6,$t7
	andi $t4,$t0,0x007fffff
	andi $t5,$t1,0x007fffff
	ori $t4,$t4,0x00800000
	ori $t5,$t5,0x00800000
	srlv $t5,$t5,$t8
	addi $t2,$t6,0
	j XuLiPhanThapPhan

MuSoThuHaiLonHon:
	sub $t8,$t7,$t6
	andi $t4,$t0,0x007fffff
	andi $t5,$t1,0x007fffff
	ori $t4,$t4,0x00800000
	ori $t5,$t5,0x00800000
	srlv $t4,$t4,$t8
	addi $t2,$t7,0  # Ta luu phan mu vo thanh ghi $t2 (8 bit)
	j XuLiPhanThapPhan
# Xu lí phan dinh tri: Sau khi phan mu da bang nhau ta tien hanh cong tru phan dinh tri nhu nguoi dung muon.
# Sau khi tien hanh cong hoac tru thi so bit cua phan dinh tri co the khac 23. Ta se dung phep dich bit de phan dinh tri co 23bit roi xu li phan mu sao cho gia tri khong thay doi. 	
XuLiPhanThapPhan:
	beq $a2,$0,Cong
	abs $s6,$t4
	abs $s7,$t5
	slt $s5,$s6,$s7
	bne $s5,$0,Tru
	sub $t9,$t4,$t5
	j DichBitSauKhiTru
Tru:
	sub $t9,$t5,$t4
	j DichBitSauKhiTru	
Cong:	add $t9,$t4,$t5
	j DichBitSauKhiCong
	
	
DichBitSauKhiCong:
	addi $s0,$0,0x00800000	
	slt $t6,$s0,$t9
	bne $t6,$0,DichPhai
	j KetQua
DichPhai:
	srl $t9,$t9,1
	addi $t2,$t2,1
DichBitSauKhiTru:
	addi $s0,$0,0x00800000	
	slt $t6,$t9,$s0
	bne $t6,$0,DichTrai
	j KetQua
DichTrai:
	sll $t9,$t9,1
	addi $t2,$t2,-1
	j DichBitSauKhiTru
KetQua:
	andi $t9,$t9,0xffffffff
	andi $t9,$t9,0x007fffff # Thanh ghi $t9 chua phan dinh tri (23 bit)
	addi $v0,$0,0
	or $v0,$v0,$t9
	sll $t2,$t2,23 # Ta dua phan mu vào
	or $v0,$v0,$t2
	sll $s4,$s4,31  # Ta dua phan dau vào
	or $v0,$v0,$s4 # Ket qua cuoi cung duoc luu vao thanh ghi $v0
	jr $ra
ToanHang1Bang0:
	bne $t0,0,ToanHang2Bang0
	addi $v0,$t1,0
	jr $ra
ToanHang2Bang0:
	addi $v0,$t0,0
	jr $ra
XuatKetQuaBang0:
	addi $v0,$0,0
	jr $ra
	




	

	
	
	
	
	
	
	
	


	
	
	
	
