

lz4w_unpack:
    move.l  4(sp),a0              ; a0 = src
    move.l  8(sp),a1              ; a1 = dst

lz4w_unpack_a:
    movem.l a2-a4,-(sp)

    lea     .next,a3               ; used for fast jump
    moveq   #0,d1

.next:
    moveq   #0,d0
    move.b  (a0)+,d0              ; d0 = literal & match length
    move.b  (a0)+,d1              ; d1 = match offset

    add.w   d0,d0
    add.w   d0,d0

.jump_base:
    move.l  (.jump_table-.jump_base)-2(pc,d0.w),a4
    jmp     (a4)

    align 2
.jump_table:

    dc.l .lit0_mat0
    dc.l .lit0_mat1
    dc.l .lit0_mat2
    dc.l .lit0_mat3
    dc.l .lit0_mat4
    dc.l .lit0_mat5
    dc.l .lit0_mat6
    dc.l .lit0_mat7
    dc.l .lit0_mat8
    dc.l .lit0_mat9
    dc.l .lit0_matA
    dc.l .lit0_matB
    dc.l .lit0_matC
    dc.l .lit0_matD
    dc.l .lit0_matE
    dc.l .lit0_matF
    dc.l .lit1_mat0
    dc.l .lit1_mat1
    dc.l .lit1_mat2
    dc.l .lit1_mat3
    dc.l .lit1_mat4
    dc.l .lit1_mat5
    dc.l .lit1_mat6
    dc.l .lit1_mat7
    dc.l .lit1_mat8
    dc.l .lit1_mat9
    dc.l .lit1_matA
    dc.l .lit1_matB
    dc.l .lit1_matC
    dc.l .lit1_matD
    dc.l .lit1_matE
    dc.l .lit1_matF
    dc.l .lit2_mat0
    dc.l .lit2_mat1
    dc.l .lit2_mat2
    dc.l .lit2_mat3
    dc.l .lit2_mat4
    dc.l .lit2_mat5
    dc.l .lit2_mat6
    dc.l .lit2_mat7
    dc.l .lit2_mat8
    dc.l .lit2_mat9
    dc.l .lit2_matA
    dc.l .lit2_matB
    dc.l .lit2_matC
    dc.l .lit2_matD
    dc.l .lit2_matE
    dc.l .lit2_matF
    dc.l .lit3_mat0
    dc.l .lit3_mat1
    dc.l .lit3_mat2
    dc.l .lit3_mat3
    dc.l .lit3_mat4
    dc.l .lit3_mat5
    dc.l .lit3_mat6
    dc.l .lit3_mat7
    dc.l .lit3_mat8
    dc.l .lit3_mat9
    dc.l .lit3_matA
    dc.l .lit3_matB
    dc.l .lit3_matC
    dc.l .lit3_matD
    dc.l .lit3_matE
    dc.l .lit3_matF
    dc.l .lit4_mat0
    dc.l .lit4_mat1
    dc.l .lit4_mat2
    dc.l .lit4_mat3
    dc.l .lit4_mat4
    dc.l .lit4_mat5
    dc.l .lit4_mat6
    dc.l .lit4_mat7
    dc.l .lit4_mat8
    dc.l .lit4_mat9
    dc.l .lit4_matA
    dc.l .lit4_matB
    dc.l .lit4_matC
    dc.l .lit4_matD
    dc.l .lit4_matE
    dc.l .lit4_matF
    dc.l .lit5_mat0
    dc.l .lit5_mat1
    dc.l .lit5_mat2
    dc.l .lit5_mat3
    dc.l .lit5_mat4
    dc.l .lit5_mat5
    dc.l .lit5_mat6
    dc.l .lit5_mat7
    dc.l .lit5_mat8
    dc.l .lit5_mat9
    dc.l .lit5_matA
    dc.l .lit5_matB
    dc.l .lit5_matC
    dc.l .lit5_matD
    dc.l .lit5_matE
    dc.l .lit5_matF
    dc.l .lit6_mat0
    dc.l .lit6_mat1
    dc.l .lit6_mat2
    dc.l .lit6_mat3
    dc.l .lit6_mat4
    dc.l .lit6_mat5
    dc.l .lit6_mat6
    dc.l .lit6_mat7
    dc.l .lit6_mat8
    dc.l .lit6_mat9
    dc.l .lit6_matA
    dc.l .lit6_matB
    dc.l .lit6_matC
    dc.l .lit6_matD
    dc.l .lit6_matE
    dc.l .lit6_matF
    dc.l .lit7_mat0
    dc.l .lit7_mat1
    dc.l .lit7_mat2
    dc.l .lit7_mat3
    dc.l .lit7_mat4
    dc.l .lit7_mat5
    dc.l .lit7_mat6
    dc.l .lit7_mat7
    dc.l .lit7_mat8
    dc.l .lit7_mat9
    dc.l .lit7_matA
    dc.l .lit7_matB
    dc.l .lit7_matC
    dc.l .lit7_matD
    dc.l .lit7_matE
    dc.l .lit7_matF
    dc.l .lit8_mat0
    dc.l .lit8_mat1
    dc.l .lit8_mat2
    dc.l .lit8_mat3
    dc.l .lit8_mat4
    dc.l .lit8_mat5
    dc.l .lit8_mat6
    dc.l .lit8_mat7
    dc.l .lit8_mat8
    dc.l .lit8_mat9
    dc.l .lit8_matA
    dc.l .lit8_matB
    dc.l .lit8_matC
    dc.l .lit8_matD
    dc.l .lit8_matE
    dc.l .lit8_matF
    dc.l .lit9_mat0
    dc.l .lit9_mat1
    dc.l .lit9_mat2
    dc.l .lit9_mat3
    dc.l .lit9_mat4
    dc.l .lit9_mat5
    dc.l .lit9_mat6
    dc.l .lit9_mat7
    dc.l .lit9_mat8
    dc.l .lit9_mat9
    dc.l .lit9_matA
    dc.l .lit9_matB
    dc.l .lit9_matC
    dc.l .lit9_matD
    dc.l .lit9_matE
    dc.l .lit9_matF
    dc.l .litA_mat0
    dc.l .litA_mat1
    dc.l .litA_mat2
    dc.l .litA_mat3
    dc.l .litA_mat4
    dc.l .litA_mat5
    dc.l .litA_mat6
    dc.l .litA_mat7
    dc.l .litA_mat8
    dc.l .litA_mat9
    dc.l .litA_matA
    dc.l .litA_matB
    dc.l .litA_matC
    dc.l .litA_matD
    dc.l .litA_matE
    dc.l .litA_matF
    dc.l .litB_mat0
    dc.l .litB_mat1
    dc.l .litB_mat2
    dc.l .litB_mat3
    dc.l .litB_mat4
    dc.l .litB_mat5
    dc.l .litB_mat6
    dc.l .litB_mat7
    dc.l .litB_mat8
    dc.l .litB_mat9
    dc.l .litB_matA
    dc.l .litB_matB
    dc.l .litB_matC
    dc.l .litB_matD
    dc.l .litB_matE
    dc.l .litB_matF
    dc.l .litC_mat0
    dc.l .litC_mat1
    dc.l .litC_mat2
    dc.l .litC_mat3
    dc.l .litC_mat4
    dc.l .litC_mat5
    dc.l .litC_mat6
    dc.l .litC_mat7
    dc.l .litC_mat8
    dc.l .litC_mat9
    dc.l .litC_matA
    dc.l .litC_matB
    dc.l .litC_matC
    dc.l .litC_matD
    dc.l .litC_matE
    dc.l .litC_matF
    dc.l .litD_mat0
    dc.l .litD_mat1
    dc.l .litD_mat2
    dc.l .litD_mat3
    dc.l .litD_mat4
    dc.l .litD_mat5
    dc.l .litD_mat6
    dc.l .litD_mat7
    dc.l .litD_mat8
    dc.l .litD_mat9
    dc.l .litD_matA
    dc.l .litD_matB
    dc.l .litD_matC
    dc.l .litD_matD
    dc.l .litD_matE
    dc.l .litD_matF
    dc.l .litE_mat0
    dc.l .litE_mat1
    dc.l .litE_mat2
    dc.l .litE_mat3
    dc.l .litE_mat4
    dc.l .litE_mat5
    dc.l .litE_mat6
    dc.l .litE_mat7
    dc.l .litE_mat8
    dc.l .litE_mat9
    dc.l .litE_matA
    dc.l .litE_matB
    dc.l .litE_matC
    dc.l .litE_matD
    dc.l .litE_matE
    dc.l .litE_matF
    dc.l .litF_mat0
    dc.l .litF_mat1
    dc.l .litF_mat2
    dc.l .litF_mat3
    dc.l .litF_mat4
    dc.l .litF_mat5
    dc.l .litF_mat6
    dc.l .litF_mat7
    dc.l .litF_mat8
    dc.l .litF_mat9
    dc.l .litF_matA
    dc.l .litF_matB
    dc.l .litF_matC
    dc.l .litF_matD
    dc.l .litF_matE
    dc.l .litF_matF

.lm_len_FF:
	move.w  (a2)+,(a1)+
.lm_len_FE:
	move.w  (a2)+,(a1)+
.lm_len_FD:
	move.w  (a2)+,(a1)+
.lm_len_FC:
	move.w  (a2)+,(a1)+
.lm_len_FB:
	move.w  (a2)+,(a1)+
.lm_len_FA:
	move.w  (a2)+,(a1)+
.lm_len_F9:
	move.w  (a2)+,(a1)+
.lm_len_F8:
	move.w  (a2)+,(a1)+
.lm_len_F7:
	move.w  (a2)+,(a1)+
.lm_len_F6:
	move.w  (a2)+,(a1)+
.lm_len_F5:
	move.w  (a2)+,(a1)+
.lm_len_F4:
	move.w  (a2)+,(a1)+
.lm_len_F3:
	move.w  (a2)+,(a1)+
.lm_len_F2:
	move.w  (a2)+,(a1)+
.lm_len_F1:
	move.w  (a2)+,(a1)+
.lm_len_F0:
	move.w  (a2)+,(a1)+
.lm_len_EF:
	move.w  (a2)+,(a1)+
.lm_len_EE:
	move.w  (a2)+,(a1)+
.lm_len_ED:
	move.w  (a2)+,(a1)+
.lm_len_EC:
	move.w  (a2)+,(a1)+
.lm_len_EB:
	move.w  (a2)+,(a1)+
.lm_len_EA:
	move.w  (a2)+,(a1)+
.lm_len_E9:
	move.w  (a2)+,(a1)+
.lm_len_E8:
	move.w  (a2)+,(a1)+
.lm_len_E7:
	move.w  (a2)+,(a1)+
.lm_len_E6:
	move.w  (a2)+,(a1)+
.lm_len_E5:
	move.w  (a2)+,(a1)+
.lm_len_E4:
	move.w  (a2)+,(a1)+
.lm_len_E3:
	move.w  (a2)+,(a1)+
.lm_len_E2:
	move.w  (a2)+,(a1)+
.lm_len_E1:
	move.w  (a2)+,(a1)+
.lm_len_E0:
	move.w  (a2)+,(a1)+
.lm_len_DF:
	move.w  (a2)+,(a1)+
.lm_len_DE:
	move.w  (a2)+,(a1)+
.lm_len_DD:
	move.w  (a2)+,(a1)+
.lm_len_DC:
	move.w  (a2)+,(a1)+
.lm_len_DB:
	move.w  (a2)+,(a1)+
.lm_len_DA:
	move.w  (a2)+,(a1)+
.lm_len_D9:
	move.w  (a2)+,(a1)+
.lm_len_D8:
	move.w  (a2)+,(a1)+
.lm_len_D7:
	move.w  (a2)+,(a1)+
.lm_len_D6:
	move.w  (a2)+,(a1)+
.lm_len_D5:
	move.w  (a2)+,(a1)+
.lm_len_D4:
	move.w  (a2)+,(a1)+
.lm_len_D3:
	move.w  (a2)+,(a1)+
.lm_len_D2:
	move.w  (a2)+,(a1)+
.lm_len_D1:
	move.w  (a2)+,(a1)+
.lm_len_D0:
	move.w  (a2)+,(a1)+
.lm_len_CF:
	move.w  (a2)+,(a1)+
.lm_len_CE:
	move.w  (a2)+,(a1)+
.lm_len_CD:
	move.w  (a2)+,(a1)+
.lm_len_CC:
	move.w  (a2)+,(a1)+
.lm_len_CB:
	move.w  (a2)+,(a1)+
.lm_len_CA:
	move.w  (a2)+,(a1)+
.lm_len_C9:
	move.w  (a2)+,(a1)+
.lm_len_C8:
	move.w  (a2)+,(a1)+
.lm_len_C7:
	move.w  (a2)+,(a1)+
.lm_len_C6:
	move.w  (a2)+,(a1)+
.lm_len_C5:
	move.w  (a2)+,(a1)+
.lm_len_C4:
	move.w  (a2)+,(a1)+
.lm_len_C3:
	move.w  (a2)+,(a1)+
.lm_len_C2:
	move.w  (a2)+,(a1)+
.lm_len_C1:
	move.w  (a2)+,(a1)+
.lm_len_C0:
	move.w  (a2)+,(a1)+
.lm_len_BF:
	move.w  (a2)+,(a1)+
.lm_len_BE:
	move.w  (a2)+,(a1)+
.lm_len_BD:
	move.w  (a2)+,(a1)+
.lm_len_BC:
	move.w  (a2)+,(a1)+
.lm_len_BB:
	move.w  (a2)+,(a1)+
.lm_len_BA:
	move.w  (a2)+,(a1)+
.lm_len_B9:
	move.w  (a2)+,(a1)+
.lm_len_B8:
	move.w  (a2)+,(a1)+
.lm_len_B7:
	move.w  (a2)+,(a1)+
.lm_len_B6:
	move.w  (a2)+,(a1)+
.lm_len_B5:
	move.w  (a2)+,(a1)+
.lm_len_B4:
	move.w  (a2)+,(a1)+
.lm_len_B3:
	move.w  (a2)+,(a1)+
.lm_len_B2:
	move.w  (a2)+,(a1)+
.lm_len_B1:
	move.w  (a2)+,(a1)+
.lm_len_B0:
	move.w  (a2)+,(a1)+
.lm_len_AF:
	move.w  (a2)+,(a1)+
.lm_len_AE:
	move.w  (a2)+,(a1)+
.lm_len_AD:
	move.w  (a2)+,(a1)+
.lm_len_AC:
	move.w  (a2)+,(a1)+
.lm_len_AB:
	move.w  (a2)+,(a1)+
.lm_len_AA:
	move.w  (a2)+,(a1)+
.lm_len_A9:
	move.w  (a2)+,(a1)+
.lm_len_A8:
	move.w  (a2)+,(a1)+
.lm_len_A7:
	move.w  (a2)+,(a1)+
.lm_len_A6:
	move.w  (a2)+,(a1)+
.lm_len_A5:
	move.w  (a2)+,(a1)+
.lm_len_A4:
	move.w  (a2)+,(a1)+
.lm_len_A3:
	move.w  (a2)+,(a1)+
.lm_len_A2:
	move.w  (a2)+,(a1)+
.lm_len_A1:
	move.w  (a2)+,(a1)+
.lm_len_A0:
	move.w  (a2)+,(a1)+
.lm_len_9F:
	move.w  (a2)+,(a1)+
.lm_len_9E:
	move.w  (a2)+,(a1)+
.lm_len_9D:
	move.w  (a2)+,(a1)+
.lm_len_9C:
	move.w  (a2)+,(a1)+
.lm_len_9B:
	move.w  (a2)+,(a1)+
.lm_len_9A:
	move.w  (a2)+,(a1)+
.lm_len_99:
	move.w  (a2)+,(a1)+
.lm_len_98:
	move.w  (a2)+,(a1)+
.lm_len_97:
	move.w  (a2)+,(a1)+
.lm_len_96:
	move.w  (a2)+,(a1)+
.lm_len_95:
	move.w  (a2)+,(a1)+
.lm_len_94:
	move.w  (a2)+,(a1)+
.lm_len_93:
	move.w  (a2)+,(a1)+
.lm_len_92:
	move.w  (a2)+,(a1)+
.lm_len_91:
	move.w  (a2)+,(a1)+
.lm_len_90:
	move.w  (a2)+,(a1)+
.lm_len_8F:
	move.w  (a2)+,(a1)+
.lm_len_8E:
	move.w  (a2)+,(a1)+
.lm_len_8D:
	move.w  (a2)+,(a1)+
.lm_len_8C:
	move.w  (a2)+,(a1)+
.lm_len_8B:
	move.w  (a2)+,(a1)+
.lm_len_8A:
	move.w  (a2)+,(a1)+
.lm_len_89:
	move.w  (a2)+,(a1)+
.lm_len_88:
	move.w  (a2)+,(a1)+
.lm_len_87:
	move.w  (a2)+,(a1)+
.lm_len_86:
	move.w  (a2)+,(a1)+
.lm_len_85:
	move.w  (a2)+,(a1)+
.lm_len_84:
	move.w  (a2)+,(a1)+
.lm_len_83:
	move.w  (a2)+,(a1)+
.lm_len_82:
	move.w  (a2)+,(a1)+
.lm_len_81:
	move.w  (a2)+,(a1)+
.lm_len_80:
	move.w  (a2)+,(a1)+
.lm_len_7F:
	move.w  (a2)+,(a1)+
.lm_len_7E:
	move.w  (a2)+,(a1)+
.lm_len_7D:
	move.w  (a2)+,(a1)+
.lm_len_7C:
	move.w  (a2)+,(a1)+
.lm_len_7B:
	move.w  (a2)+,(a1)+
.lm_len_7A:
	move.w  (a2)+,(a1)+
.lm_len_79:
	move.w  (a2)+,(a1)+
.lm_len_78:
	move.w  (a2)+,(a1)+
.lm_len_77:
	move.w  (a2)+,(a1)+
.lm_len_76:
	move.w  (a2)+,(a1)+
.lm_len_75:
	move.w  (a2)+,(a1)+
.lm_len_74:
	move.w  (a2)+,(a1)+
.lm_len_73:
	move.w  (a2)+,(a1)+
.lm_len_72:
	move.w  (a2)+,(a1)+
.lm_len_71:
	move.w  (a2)+,(a1)+
.lm_len_70:
	move.w  (a2)+,(a1)+
.lm_len_6F:
	move.w  (a2)+,(a1)+
.lm_len_6E:
	move.w  (a2)+,(a1)+
.lm_len_6D:
	move.w  (a2)+,(a1)+
.lm_len_6C:
	move.w  (a2)+,(a1)+
.lm_len_6B:
	move.w  (a2)+,(a1)+
.lm_len_6A:
	move.w  (a2)+,(a1)+
.lm_len_69:
	move.w  (a2)+,(a1)+
.lm_len_68:
	move.w  (a2)+,(a1)+
.lm_len_67:
	move.w  (a2)+,(a1)+
.lm_len_66:
	move.w  (a2)+,(a1)+
.lm_len_65:
	move.w  (a2)+,(a1)+
.lm_len_64:
	move.w  (a2)+,(a1)+
.lm_len_63:
	move.w  (a2)+,(a1)+
.lm_len_62:
	move.w  (a2)+,(a1)+
.lm_len_61:
	move.w  (a2)+,(a1)+
.lm_len_60:
	move.w  (a2)+,(a1)+
.lm_len_5F:
	move.w  (a2)+,(a1)+
.lm_len_5E:
	move.w  (a2)+,(a1)+
.lm_len_5D:
	move.w  (a2)+,(a1)+
.lm_len_5C:
	move.w  (a2)+,(a1)+
.lm_len_5B:
	move.w  (a2)+,(a1)+
.lm_len_5A:
	move.w  (a2)+,(a1)+
.lm_len_59:
	move.w  (a2)+,(a1)+
.lm_len_58:
	move.w  (a2)+,(a1)+
.lm_len_57:
	move.w  (a2)+,(a1)+
.lm_len_56:
	move.w  (a2)+,(a1)+
.lm_len_55:
	move.w  (a2)+,(a1)+
.lm_len_54:
	move.w  (a2)+,(a1)+
.lm_len_53:
	move.w  (a2)+,(a1)+
.lm_len_52:
	move.w  (a2)+,(a1)+
.lm_len_51:
	move.w  (a2)+,(a1)+
.lm_len_50:
	move.w  (a2)+,(a1)+
.lm_len_4F:
	move.w  (a2)+,(a1)+
.lm_len_4E:
	move.w  (a2)+,(a1)+
.lm_len_4D:
	move.w  (a2)+,(a1)+
.lm_len_4C:
	move.w  (a2)+,(a1)+
.lm_len_4B:
	move.w  (a2)+,(a1)+
.lm_len_4A:
	move.w  (a2)+,(a1)+
.lm_len_49:
	move.w  (a2)+,(a1)+
.lm_len_48:
	move.w  (a2)+,(a1)+
.lm_len_47:
	move.w  (a2)+,(a1)+
.lm_len_46:
	move.w  (a2)+,(a1)+
.lm_len_45:
	move.w  (a2)+,(a1)+
.lm_len_44:
	move.w  (a2)+,(a1)+
.lm_len_43:
	move.w  (a2)+,(a1)+
.lm_len_42:
	move.w  (a2)+,(a1)+
.lm_len_41:
	move.w  (a2)+,(a1)+
.lm_len_40:
	move.w  (a2)+,(a1)+
.lm_len_3F:
	move.w  (a2)+,(a1)+
.lm_len_3E:
	move.w  (a2)+,(a1)+
.lm_len_3D:
	move.w  (a2)+,(a1)+
.lm_len_3C:
	move.w  (a2)+,(a1)+
.lm_len_3B:
	move.w  (a2)+,(a1)+
.lm_len_3A:
	move.w  (a2)+,(a1)+
.lm_len_39:
	move.w  (a2)+,(a1)+
.lm_len_38:
	move.w  (a2)+,(a1)+
.lm_len_37:
	move.w  (a2)+,(a1)+
.lm_len_36:
	move.w  (a2)+,(a1)+
.lm_len_35:
	move.w  (a2)+,(a1)+
.lm_len_34:
	move.w  (a2)+,(a1)+
.lm_len_33:
	move.w  (a2)+,(a1)+
.lm_len_32:
	move.w  (a2)+,(a1)+
.lm_len_31:
	move.w  (a2)+,(a1)+
.lm_len_30:
	move.w  (a2)+,(a1)+
.lm_len_2F:
	move.w  (a2)+,(a1)+
.lm_len_2E:
	move.w  (a2)+,(a1)+
.lm_len_2D:
	move.w  (a2)+,(a1)+
.lm_len_2C:
	move.w  (a2)+,(a1)+
.lm_len_2B:
	move.w  (a2)+,(a1)+
.lm_len_2A:
	move.w  (a2)+,(a1)+
.lm_len_29:
	move.w  (a2)+,(a1)+
.lm_len_28:
	move.w  (a2)+,(a1)+
.lm_len_27:
	move.w  (a2)+,(a1)+
.lm_len_26:
	move.w  (a2)+,(a1)+
.lm_len_25:
	move.w  (a2)+,(a1)+
.lm_len_24:
	move.w  (a2)+,(a1)+
.lm_len_23:
	move.w  (a2)+,(a1)+
.lm_len_22:
	move.w  (a2)+,(a1)+
.lm_len_21:
	move.w  (a2)+,(a1)+
.lm_len_20:
	move.w  (a2)+,(a1)+
.lm_len_1F:
	move.w  (a2)+,(a1)+
.lm_len_1E:
	move.w  (a2)+,(a1)+
.lm_len_1D:
	move.w  (a2)+,(a1)+
.lm_len_1C:
	move.w  (a2)+,(a1)+
.lm_len_1B:
	move.w  (a2)+,(a1)+
.lm_len_1A:
	move.w  (a2)+,(a1)+
.lm_len_19:
	move.w  (a2)+,(a1)+
.lm_len_18:
	move.w  (a2)+,(a1)+
.lm_len_17:
	move.w  (a2)+,(a1)+
.lm_len_16:
	move.w  (a2)+,(a1)+
.lm_len_15:
	move.w  (a2)+,(a1)+
.lm_len_14:
	move.w  (a2)+,(a1)+
.lm_len_13:
	move.w  (a2)+,(a1)+
.lm_len_12:
	move.w  (a2)+,(a1)+
.lm_len_11:
	move.w  (a2)+,(a1)+
.lm_len_10:
	move.w  (a2)+,(a1)+
.lm_len_0F:
	move.w  (a2)+,(a1)+
.lm_len_0E:
	move.w  (a2)+,(a1)+
.lm_len_0D:
	move.w  (a2)+,(a1)+
.lm_len_0C:
	move.w  (a2)+,(a1)+
.lm_len_0B:
	move.w  (a2)+,(a1)+
.lm_len_0A:
	move.w  (a2)+,(a1)+
.lm_len_09:
	move.w  (a2)+,(a1)+
.lm_len_08:
	move.w  (a2)+,(a1)+
.lm_len_07:
	move.w  (a2)+,(a1)+
.lm_len_06:
	move.w  (a2)+,(a1)+
.lm_len_05:
	move.w  (a2)+,(a1)+
.lm_len_04:
	move.w  (a2)+,(a1)+
.lm_len_03:
	move.w  (a2)+,(a1)+
.lm_len_02:
	move.w  (a2)+,(a1)+
.lm_len_01:
	move.w  (a2)+,(a1)+
.lm_len_00:
	move.w  (a2)+,(a1)+
	move.w  (a2)+,(a1)+

    moveq   #0,d0
    moveq   #0,d1
    jmp     (a3)

.lmr_len_FF:
	move.l  (a2)+,(a1)+
.lmr_len_FD:
	move.l  (a2)+,(a1)+
.lmr_len_FB:
	move.l  (a2)+,(a1)+
.lmr_len_F9:
	move.l  (a2)+,(a1)+
.lmr_len_F7:
	move.l  (a2)+,(a1)+
.lmr_len_F5:
	move.l  (a2)+,(a1)+
.lmr_len_F3:
	move.l  (a2)+,(a1)+
.lmr_len_F1:
	move.l  (a2)+,(a1)+
.lmr_len_EF:
	move.l  (a2)+,(a1)+
.lmr_len_ED:
	move.l  (a2)+,(a1)+
.lmr_len_EB:
	move.l  (a2)+,(a1)+
.lmr_len_E9:
	move.l  (a2)+,(a1)+
.lmr_len_E7:
	move.l  (a2)+,(a1)+
.lmr_len_E5:
	move.l  (a2)+,(a1)+
.lmr_len_E3:
	move.l  (a2)+,(a1)+
.lmr_len_E1:
	move.l  (a2)+,(a1)+
.lmr_len_DF:
	move.l  (a2)+,(a1)+
.lmr_len_DD:
	move.l  (a2)+,(a1)+
.lmr_len_DB:
	move.l  (a2)+,(a1)+
.lmr_len_D9:
	move.l  (a2)+,(a1)+
.lmr_len_D7:
	move.l  (a2)+,(a1)+
.lmr_len_D5:
	move.l  (a2)+,(a1)+
.lmr_len_D3:
	move.l  (a2)+,(a1)+
.lmr_len_D1:
	move.l  (a2)+,(a1)+
.lmr_len_CF:
	move.l  (a2)+,(a1)+
.lmr_len_CD:
	move.l  (a2)+,(a1)+
.lmr_len_CB:
	move.l  (a2)+,(a1)+
.lmr_len_C9:
	move.l  (a2)+,(a1)+
.lmr_len_C7:
	move.l  (a2)+,(a1)+
.lmr_len_C5:
	move.l  (a2)+,(a1)+
.lmr_len_C3:
	move.l  (a2)+,(a1)+
.lmr_len_C1:
	move.l  (a2)+,(a1)+
.lmr_len_BF:
	move.l  (a2)+,(a1)+
.lmr_len_BD:
	move.l  (a2)+,(a1)+
.lmr_len_BB:
	move.l  (a2)+,(a1)+
.lmr_len_B9:
	move.l  (a2)+,(a1)+
.lmr_len_B7:
	move.l  (a2)+,(a1)+
.lmr_len_B5:
	move.l  (a2)+,(a1)+
.lmr_len_B3:
	move.l  (a2)+,(a1)+
.lmr_len_B1:
	move.l  (a2)+,(a1)+
.lmr_len_AF:
	move.l  (a2)+,(a1)+
.lmr_len_AD:
	move.l  (a2)+,(a1)+
.lmr_len_AB:
	move.l  (a2)+,(a1)+
.lmr_len_A9:
	move.l  (a2)+,(a1)+
.lmr_len_A7:
	move.l  (a2)+,(a1)+
.lmr_len_A5:
	move.l  (a2)+,(a1)+
.lmr_len_A3:
	move.l  (a2)+,(a1)+
.lmr_len_A1:
	move.l  (a2)+,(a1)+
.lmr_len_9F:
	move.l  (a2)+,(a1)+
.lmr_len_9D:
	move.l  (a2)+,(a1)+
.lmr_len_9B:
	move.l  (a2)+,(a1)+
.lmr_len_99:
	move.l  (a2)+,(a1)+
.lmr_len_97:
	move.l  (a2)+,(a1)+
.lmr_len_95:
	move.l  (a2)+,(a1)+
.lmr_len_93:
	move.l  (a2)+,(a1)+
.lmr_len_91:
	move.l  (a2)+,(a1)+
.lmr_len_8F:
	move.l  (a2)+,(a1)+
.lmr_len_8D:
	move.l  (a2)+,(a1)+
.lmr_len_8B:
	move.l  (a2)+,(a1)+
.lmr_len_89:
	move.l  (a2)+,(a1)+
.lmr_len_87:
	move.l  (a2)+,(a1)+
.lmr_len_85:
	move.l  (a2)+,(a1)+
.lmr_len_83:
	move.l  (a2)+,(a1)+
.lmr_len_81:
	move.l  (a2)+,(a1)+
.lmr_len_7F:
	move.l  (a2)+,(a1)+
.lmr_len_7D:
	move.l  (a2)+,(a1)+
.lmr_len_7B:
	move.l  (a2)+,(a1)+
.lmr_len_79:
	move.l  (a2)+,(a1)+
.lmr_len_77:
	move.l  (a2)+,(a1)+
.lmr_len_75:
	move.l  (a2)+,(a1)+
.lmr_len_73:
	move.l  (a2)+,(a1)+
.lmr_len_71:
	move.l  (a2)+,(a1)+
.lmr_len_6F:
	move.l  (a2)+,(a1)+
.lmr_len_6D:
	move.l  (a2)+,(a1)+
.lmr_len_6B:
	move.l  (a2)+,(a1)+
.lmr_len_69:
	move.l  (a2)+,(a1)+
.lmr_len_67:
	move.l  (a2)+,(a1)+
.lmr_len_65:
	move.l  (a2)+,(a1)+
.lmr_len_63:
	move.l  (a2)+,(a1)+
.lmr_len_61:
	move.l  (a2)+,(a1)+
.lmr_len_5F:
	move.l  (a2)+,(a1)+
.lmr_len_5D:
	move.l  (a2)+,(a1)+
.lmr_len_5B:
	move.l  (a2)+,(a1)+
.lmr_len_59:
	move.l  (a2)+,(a1)+
.lmr_len_57:
	move.l  (a2)+,(a1)+
.lmr_len_55:
	move.l  (a2)+,(a1)+
.lmr_len_53:
	move.l  (a2)+,(a1)+
.lmr_len_51:
	move.l  (a2)+,(a1)+
.lmr_len_4F:
	move.l  (a2)+,(a1)+
.lmr_len_4D:
	move.l  (a2)+,(a1)+
.lmr_len_4B:
	move.l  (a2)+,(a1)+
.lmr_len_49:
	move.l  (a2)+,(a1)+
.lmr_len_47:
	move.l  (a2)+,(a1)+
.lmr_len_45:
	move.l  (a2)+,(a1)+
.lmr_len_43:
	move.l  (a2)+,(a1)+
.lmr_len_41:
	move.l  (a2)+,(a1)+
.lmr_len_3F:
	move.l  (a2)+,(a1)+
.lmr_len_3D:
	move.l  (a2)+,(a1)+
.lmr_len_3B:
	move.l  (a2)+,(a1)+
.lmr_len_39:
	move.l  (a2)+,(a1)+
.lmr_len_37:
	move.l  (a2)+,(a1)+
.lmr_len_35:
	move.l  (a2)+,(a1)+
.lmr_len_33:
	move.l  (a2)+,(a1)+
.lmr_len_31:
	move.l  (a2)+,(a1)+
.lmr_len_2F:
	move.l  (a2)+,(a1)+
.lmr_len_2D:
	move.l  (a2)+,(a1)+
.lmr_len_2B:
	move.l  (a2)+,(a1)+
.lmr_len_29:
	move.l  (a2)+,(a1)+
.lmr_len_27:
	move.l  (a2)+,(a1)+
.lmr_len_25:
	move.l  (a2)+,(a1)+
.lmr_len_23:
	move.l  (a2)+,(a1)+
.lmr_len_21:
	move.l  (a2)+,(a1)+
.lmr_len_1F:
	move.l  (a2)+,(a1)+
.lmr_len_1D:
	move.l  (a2)+,(a1)+
.lmr_len_1B:
	move.l  (a2)+,(a1)+
.lmr_len_19:
	move.l  (a2)+,(a1)+
.lmr_len_17:
	move.l  (a2)+,(a1)+
.lmr_len_15:
	move.l  (a2)+,(a1)+
.lmr_len_13:
	move.l  (a2)+,(a1)+
.lmr_len_11:
	move.l  (a2)+,(a1)+
.lmr_len_0F:
	move.l  (a2)+,(a1)+
.lmr_len_0D:
	move.l  (a2)+,(a1)+
.lmr_len_0B:
	move.l  (a2)+,(a1)+
.lmr_len_09:
	move.l  (a2)+,(a1)+
.lmr_len_07:
	move.l  (a2)+,(a1)+
.lmr_len_05:
	move.l  (a2)+,(a1)+
.lmr_len_03:
	move.l  (a2)+,(a1)+
.lmr_len_01:
	move.l  (a2)+,(a1)+
	move.w  (a2)+,(a1)+

    moveq   #0,d0
    moveq   #0,d1
    jmp     (a3)

.lmr_len_FE:
	move.l  (a2)+,(a1)+
.lmr_len_FC:
	move.l  (a2)+,(a1)+
.lmr_len_FA:
	move.l  (a2)+,(a1)+
.lmr_len_F8:
	move.l  (a2)+,(a1)+
.lmr_len_F6:
	move.l  (a2)+,(a1)+
.lmr_len_F4:
	move.l  (a2)+,(a1)+
.lmr_len_F2:
	move.l  (a2)+,(a1)+
.lmr_len_F0:
	move.l  (a2)+,(a1)+
.lmr_len_EE:
	move.l  (a2)+,(a1)+
.lmr_len_EC:
	move.l  (a2)+,(a1)+
.lmr_len_EA:
	move.l  (a2)+,(a1)+
.lmr_len_E8:
	move.l  (a2)+,(a1)+
.lmr_len_E6:
	move.l  (a2)+,(a1)+
.lmr_len_E4:
	move.l  (a2)+,(a1)+
.lmr_len_E2:
	move.l  (a2)+,(a1)+
.lmr_len_E0:
	move.l  (a2)+,(a1)+
.lmr_len_DE:
	move.l  (a2)+,(a1)+
.lmr_len_DC:
	move.l  (a2)+,(a1)+
.lmr_len_DA:
	move.l  (a2)+,(a1)+
.lmr_len_D8:
	move.l  (a2)+,(a1)+
.lmr_len_D6:
	move.l  (a2)+,(a1)+
.lmr_len_D4:
	move.l  (a2)+,(a1)+
.lmr_len_D2:
	move.l  (a2)+,(a1)+
.lmr_len_D0:
	move.l  (a2)+,(a1)+
.lmr_len_CE:
	move.l  (a2)+,(a1)+
.lmr_len_CC:
	move.l  (a2)+,(a1)+
.lmr_len_CA:
	move.l  (a2)+,(a1)+
.lmr_len_C8:
	move.l  (a2)+,(a1)+
.lmr_len_C6:
	move.l  (a2)+,(a1)+
.lmr_len_C4:
	move.l  (a2)+,(a1)+
.lmr_len_C2:
	move.l  (a2)+,(a1)+
.lmr_len_C0:
	move.l  (a2)+,(a1)+
.lmr_len_BE:
	move.l  (a2)+,(a1)+
.lmr_len_BC:
	move.l  (a2)+,(a1)+
.lmr_len_BA:
	move.l  (a2)+,(a1)+
.lmr_len_B8:
	move.l  (a2)+,(a1)+
.lmr_len_B6:
	move.l  (a2)+,(a1)+
.lmr_len_B4:
	move.l  (a2)+,(a1)+
.lmr_len_B2:
	move.l  (a2)+,(a1)+
.lmr_len_B0:
	move.l  (a2)+,(a1)+
.lmr_len_AE:
	move.l  (a2)+,(a1)+
.lmr_len_AC:
	move.l  (a2)+,(a1)+
.lmr_len_AA:
	move.l  (a2)+,(a1)+
.lmr_len_A8:
	move.l  (a2)+,(a1)+
.lmr_len_A6:
	move.l  (a2)+,(a1)+
.lmr_len_A4:
	move.l  (a2)+,(a1)+
.lmr_len_A2:
	move.l  (a2)+,(a1)+
.lmr_len_A0:
	move.l  (a2)+,(a1)+
.lmr_len_9E:
	move.l  (a2)+,(a1)+
.lmr_len_9C:
	move.l  (a2)+,(a1)+
.lmr_len_9A:
	move.l  (a2)+,(a1)+
.lmr_len_98:
	move.l  (a2)+,(a1)+
.lmr_len_96:
	move.l  (a2)+,(a1)+
.lmr_len_94:
	move.l  (a2)+,(a1)+
.lmr_len_92:
	move.l  (a2)+,(a1)+
.lmr_len_90:
	move.l  (a2)+,(a1)+
.lmr_len_8E:
	move.l  (a2)+,(a1)+
.lmr_len_8C:
	move.l  (a2)+,(a1)+
.lmr_len_8A:
	move.l  (a2)+,(a1)+
.lmr_len_88:
	move.l  (a2)+,(a1)+
.lmr_len_86:
	move.l  (a2)+,(a1)+
.lmr_len_84:
	move.l  (a2)+,(a1)+
.lmr_len_82:
	move.l  (a2)+,(a1)+
.lmr_len_80:
	move.l  (a2)+,(a1)+
.lmr_len_7E:
	move.l  (a2)+,(a1)+
.lmr_len_7C:
	move.l  (a2)+,(a1)+
.lmr_len_7A:
	move.l  (a2)+,(a1)+
.lmr_len_78:
	move.l  (a2)+,(a1)+
.lmr_len_76:
	move.l  (a2)+,(a1)+
.lmr_len_74:
	move.l  (a2)+,(a1)+
.lmr_len_72:
	move.l  (a2)+,(a1)+
.lmr_len_70:
	move.l  (a2)+,(a1)+
.lmr_len_6E:
	move.l  (a2)+,(a1)+
.lmr_len_6C:
	move.l  (a2)+,(a1)+
.lmr_len_6A:
	move.l  (a2)+,(a1)+
.lmr_len_68:
	move.l  (a2)+,(a1)+
.lmr_len_66:
	move.l  (a2)+,(a1)+
.lmr_len_64:
	move.l  (a2)+,(a1)+
.lmr_len_62:
	move.l  (a2)+,(a1)+
.lmr_len_60:
	move.l  (a2)+,(a1)+
.lmr_len_5E:
	move.l  (a2)+,(a1)+
.lmr_len_5C:
	move.l  (a2)+,(a1)+
.lmr_len_5A:
	move.l  (a2)+,(a1)+
.lmr_len_58:
	move.l  (a2)+,(a1)+
.lmr_len_56:
	move.l  (a2)+,(a1)+
.lmr_len_54:
	move.l  (a2)+,(a1)+
.lmr_len_52:
	move.l  (a2)+,(a1)+
.lmr_len_50:
	move.l  (a2)+,(a1)+
.lmr_len_4E:
	move.l  (a2)+,(a1)+
.lmr_len_4C:
	move.l  (a2)+,(a1)+
.lmr_len_4A:
	move.l  (a2)+,(a1)+
.lmr_len_48:
	move.l  (a2)+,(a1)+
.lmr_len_46:
	move.l  (a2)+,(a1)+
.lmr_len_44:
	move.l  (a2)+,(a1)+
.lmr_len_42:
	move.l  (a2)+,(a1)+
.lmr_len_40:
	move.l  (a2)+,(a1)+
.lmr_len_3E:
	move.l  (a2)+,(a1)+
.lmr_len_3C:
	move.l  (a2)+,(a1)+
.lmr_len_3A:
	move.l  (a2)+,(a1)+
.lmr_len_38:
	move.l  (a2)+,(a1)+
.lmr_len_36:
	move.l  (a2)+,(a1)+
.lmr_len_34:
	move.l  (a2)+,(a1)+
.lmr_len_32:
	move.l  (a2)+,(a1)+
.lmr_len_30:
	move.l  (a2)+,(a1)+
.lmr_len_2E:
	move.l  (a2)+,(a1)+
.lmr_len_2C:
	move.l  (a2)+,(a1)+
.lmr_len_2A:
	move.l  (a2)+,(a1)+
.lmr_len_28:
	move.l  (a2)+,(a1)+
.lmr_len_26:
	move.l  (a2)+,(a1)+
.lmr_len_24:
	move.l  (a2)+,(a1)+
.lmr_len_22:
	move.l  (a2)+,(a1)+
.lmr_len_20:
	move.l  (a2)+,(a1)+
.lmr_len_1E:
	move.l  (a2)+,(a1)+
.lmr_len_1C:
	move.l  (a2)+,(a1)+
.lmr_len_1A:
	move.l  (a2)+,(a1)+
.lmr_len_18:
	move.l  (a2)+,(a1)+
.lmr_len_16:
	move.l  (a2)+,(a1)+
.lmr_len_14:
	move.l  (a2)+,(a1)+
.lmr_len_12:
	move.l  (a2)+,(a1)+
.lmr_len_10:
	move.l  (a2)+,(a1)+
.lmr_len_0E:
	move.l  (a2)+,(a1)+
.lmr_len_0C:
	move.l  (a2)+,(a1)+
.lmr_len_0A:
	move.l  (a2)+,(a1)+
.lmr_len_08:
	move.l  (a2)+,(a1)+
.lmr_len_06:
	move.l  (a2)+,(a1)+
.lmr_len_04:
	move.l  (a2)+,(a1)+
.lmr_len_02:
	move.l  (a2)+,(a1)+
.lmr_len_00:
	move.l  (a2)+,(a1)+

    moveq   #0,d0
    moveq   #0,d1
    jmp     (a3)


.litE_mat0:
    move.l  (a0)+,(a1)+
.litC_mat0:
    move.l  (a0)+,(a1)+
.litA_mat0:
    move.l  (a0)+,(a1)+
.lit8_mat0:
    move.l  (a0)+,(a1)+
.lit6_mat0:
    move.l  (a0)+,(a1)+
.lit4_mat0:
    move.l  (a0)+,(a1)+
.lit2_mat0:
    move.l  (a0)+,(a1)+

    tst.b   d1                     ; match offset null ?
    beq     .next                   ; not a long match

.long_match_1:
    move.w  (a0)+,d0              ; get long offset (already negated)

    add.w   d1,d1                 ;
    add.w   d1,d1                 ; len = len * 4 (for jump table)

    add.w   d0,d0                 ; bit 15 contains ROM source info
    bcs     .lm_rom

    lea     -2(a1,d0.w),a2       ; a2 = dst - (match offset + 2)

.lm1_jump_base:
    move.l  (.lm_jump_table-.lm1_jump_base)-2(pc,d1.w),a4
    jmp     (a4)

.litF_mat0:
    move.l  (a0)+,(a1)+
.litD_mat0:
    move.l  (a0)+,(a1)+
.litB_mat0:
    move.l  (a0)+,(a1)+
.lit9_mat0:
    move.l  (a0)+,(a1)+
.lit7_mat0:
    move.l  (a0)+,(a1)+
.lit5_mat0:
    move.l  (a0)+,(a1)+
.lit3_mat0:
    move.l  (a0)+,(a1)+
.lit1_mat0:
    move.w  (a0)+,(a1)+

    tst.b   d1                     ; match offset null ?
    beq     .next                   ; not a long match

.long_match_2:
    move.w  (a0)+,d0              ; get long offset (already negated)

    add.w   d1,d1                 ;
    add.w   d1,d1                 ; len = len * 4 (for jump table)

    add.w   d0,d0                 ; bit 15 contains ROM source info
    bcs     .lm_rom

    lea     -2(a1,d0.w),a2       ; a2 = dst - (match offset + 2)

.lm2_jump_base:
    move.l  (.lm_jump_table-.lm2_jump_base)-2(pc,d1.w),a4
    jmp     (a4)


.lit0_mat0:                         ; special case of lit=0 and mat=0
    tst.b   d1                     ; match offset null ?
    beq    .done                    ; not a long match --> done

.long_match_3:
    move.w  (a0)+,d0              ; get long offset (already negated)

    add.w   d1,d1                 ;
    add.w   d1,d1                 ; len = len * 4 (for jump table)

    add.w   d0,d0                 ; bit 15 contains ROM source info
    bcs     .lm_rom

    lea     -2(a1,d0.w),a2       ; a2 = dst - (match offset + 2)

.lm3_jump_base:
    move.l  (.lm_jump_table-.lm3_jump_base)-2(pc,d1.w),a4
    jmp     (a4)

    align 2
.lm_jump_table:

    dc.l .lm_len_00
    dc.l .lm_len_01
    dc.l .lm_len_02
    dc.l .lm_len_03
    dc.l .lm_len_04
    dc.l .lm_len_05
    dc.l .lm_len_06
    dc.l .lm_len_07
    dc.l .lm_len_08
    dc.l .lm_len_09
    dc.l .lm_len_0A
    dc.l .lm_len_0B
    dc.l .lm_len_0C
    dc.l .lm_len_0D
    dc.l .lm_len_0E
    dc.l .lm_len_0F
    dc.l .lm_len_10
    dc.l .lm_len_11
    dc.l .lm_len_12
    dc.l .lm_len_13
    dc.l .lm_len_14
    dc.l .lm_len_15
    dc.l .lm_len_16
    dc.l .lm_len_17
    dc.l .lm_len_18
    dc.l .lm_len_19
    dc.l .lm_len_1A
    dc.l .lm_len_1B
    dc.l .lm_len_1C
    dc.l .lm_len_1D
    dc.l .lm_len_1E
    dc.l .lm_len_1F
    dc.l .lm_len_20
    dc.l .lm_len_21
    dc.l .lm_len_22
    dc.l .lm_len_23
    dc.l .lm_len_24
    dc.l .lm_len_25
    dc.l .lm_len_26
    dc.l .lm_len_27
    dc.l .lm_len_28
    dc.l .lm_len_29
    dc.l .lm_len_2A
    dc.l .lm_len_2B
    dc.l .lm_len_2C
    dc.l .lm_len_2D
    dc.l .lm_len_2E
    dc.l .lm_len_2F
    dc.l .lm_len_30
    dc.l .lm_len_31
    dc.l .lm_len_32
    dc.l .lm_len_33
    dc.l .lm_len_34
    dc.l .lm_len_35
    dc.l .lm_len_36
    dc.l .lm_len_37
    dc.l .lm_len_38
    dc.l .lm_len_39
    dc.l .lm_len_3A
    dc.l .lm_len_3B
    dc.l .lm_len_3C
    dc.l .lm_len_3D
    dc.l .lm_len_3E
    dc.l .lm_len_3F
    dc.l .lm_len_40
    dc.l .lm_len_41
    dc.l .lm_len_42
    dc.l .lm_len_43
    dc.l .lm_len_44
    dc.l .lm_len_45
    dc.l .lm_len_46
    dc.l .lm_len_47
    dc.l .lm_len_48
    dc.l .lm_len_49
    dc.l .lm_len_4A
    dc.l .lm_len_4B
    dc.l .lm_len_4C
    dc.l .lm_len_4D
    dc.l .lm_len_4E
    dc.l .lm_len_4F
    dc.l .lm_len_50
    dc.l .lm_len_51
    dc.l .lm_len_52
    dc.l .lm_len_53
    dc.l .lm_len_54
    dc.l .lm_len_55
    dc.l .lm_len_56
    dc.l .lm_len_57
    dc.l .lm_len_58
    dc.l .lm_len_59
    dc.l .lm_len_5A
    dc.l .lm_len_5B
    dc.l .lm_len_5C
    dc.l .lm_len_5D
    dc.l .lm_len_5E
    dc.l .lm_len_5F
    dc.l .lm_len_60
    dc.l .lm_len_61
    dc.l .lm_len_62
    dc.l .lm_len_63
    dc.l .lm_len_64
    dc.l .lm_len_65
    dc.l .lm_len_66
    dc.l .lm_len_67
    dc.l .lm_len_68
    dc.l .lm_len_69
    dc.l .lm_len_6A
    dc.l .lm_len_6B
    dc.l .lm_len_6C
    dc.l .lm_len_6D
    dc.l .lm_len_6E
    dc.l .lm_len_6F
    dc.l .lm_len_70
    dc.l .lm_len_71
    dc.l .lm_len_72
    dc.l .lm_len_73
    dc.l .lm_len_74
    dc.l .lm_len_75
    dc.l .lm_len_76
    dc.l .lm_len_77
    dc.l .lm_len_78
    dc.l .lm_len_79
    dc.l .lm_len_7A
    dc.l .lm_len_7B
    dc.l .lm_len_7C
    dc.l .lm_len_7D
    dc.l .lm_len_7E
    dc.l .lm_len_7F
    dc.l .lm_len_80
    dc.l .lm_len_81
    dc.l .lm_len_82
    dc.l .lm_len_83
    dc.l .lm_len_84
    dc.l .lm_len_85
    dc.l .lm_len_86
    dc.l .lm_len_87
    dc.l .lm_len_88
    dc.l .lm_len_89
    dc.l .lm_len_8A
    dc.l .lm_len_8B
    dc.l .lm_len_8C
    dc.l .lm_len_8D
    dc.l .lm_len_8E
    dc.l .lm_len_8F
    dc.l .lm_len_90
    dc.l .lm_len_91
    dc.l .lm_len_92
    dc.l .lm_len_93
    dc.l .lm_len_94
    dc.l .lm_len_95
    dc.l .lm_len_96
    dc.l .lm_len_97
    dc.l .lm_len_98
    dc.l .lm_len_99
    dc.l .lm_len_9A
    dc.l .lm_len_9B
    dc.l .lm_len_9C
    dc.l .lm_len_9D
    dc.l .lm_len_9E
    dc.l .lm_len_9F
    dc.l .lm_len_A0
    dc.l .lm_len_A1
    dc.l .lm_len_A2
    dc.l .lm_len_A3
    dc.l .lm_len_A4
    dc.l .lm_len_A5
    dc.l .lm_len_A6
    dc.l .lm_len_A7
    dc.l .lm_len_A8
    dc.l .lm_len_A9
    dc.l .lm_len_AA
    dc.l .lm_len_AB
    dc.l .lm_len_AC
    dc.l .lm_len_AD
    dc.l .lm_len_AE
    dc.l .lm_len_AF
    dc.l .lm_len_B0
    dc.l .lm_len_B1
    dc.l .lm_len_B2
    dc.l .lm_len_B3
    dc.l .lm_len_B4
    dc.l .lm_len_B5
    dc.l .lm_len_B6
    dc.l .lm_len_B7
    dc.l .lm_len_B8
    dc.l .lm_len_B9
    dc.l .lm_len_BA
    dc.l .lm_len_BB
    dc.l .lm_len_BC
    dc.l .lm_len_BD
    dc.l .lm_len_BE
    dc.l .lm_len_BF
    dc.l .lm_len_C0
    dc.l .lm_len_C1
    dc.l .lm_len_C2
    dc.l .lm_len_C3
    dc.l .lm_len_C4
    dc.l .lm_len_C5
    dc.l .lm_len_C6
    dc.l .lm_len_C7
    dc.l .lm_len_C8
    dc.l .lm_len_C9
    dc.l .lm_len_CA
    dc.l .lm_len_CB
    dc.l .lm_len_CC
    dc.l .lm_len_CD
    dc.l .lm_len_CE
    dc.l .lm_len_CF
    dc.l .lm_len_D0
    dc.l .lm_len_D1
    dc.l .lm_len_D2
    dc.l .lm_len_D3
    dc.l .lm_len_D4
    dc.l .lm_len_D5
    dc.l .lm_len_D6
    dc.l .lm_len_D7
    dc.l .lm_len_D8
    dc.l .lm_len_D9
    dc.l .lm_len_DA
    dc.l .lm_len_DB
    dc.l .lm_len_DC
    dc.l .lm_len_DD
    dc.l .lm_len_DE
    dc.l .lm_len_DF
    dc.l .lm_len_E0
    dc.l .lm_len_E1
    dc.l .lm_len_E2
    dc.l .lm_len_E3
    dc.l .lm_len_E4
    dc.l .lm_len_E5
    dc.l .lm_len_E6
    dc.l .lm_len_E7
    dc.l .lm_len_E8
    dc.l .lm_len_E9
    dc.l .lm_len_EA
    dc.l .lm_len_EB
    dc.l .lm_len_EC
    dc.l .lm_len_ED
    dc.l .lm_len_EE
    dc.l .lm_len_EF
    dc.l .lm_len_F0
    dc.l .lm_len_F1
    dc.l .lm_len_F2
    dc.l .lm_len_F3
    dc.l .lm_len_F4
    dc.l .lm_len_F5
    dc.l .lm_len_F6
    dc.l .lm_len_F7
    dc.l .lm_len_F8
    dc.l .lm_len_F9
    dc.l .lm_len_FA
    dc.l .lm_len_FB
    dc.l .lm_len_FC
    dc.l .lm_len_FD
    dc.l .lm_len_FE
    dc.l .lm_len_FF

.lm_rom:
    lea     -2(a0,d0.w),a2       ; a2 = src - (match offset + 2)

.lmr_jump_base:
    move.l  (.lmr_jump_table-.lmr_jump_base)-2(pc,d1.w),a4
    jmp     (a4)

    align 2
.lmr_jump_table:

    dc.l .lmr_len_00
    dc.l .lmr_len_01
    dc.l .lmr_len_02
    dc.l .lmr_len_03
    dc.l .lmr_len_04
    dc.l .lmr_len_05
    dc.l .lmr_len_06
    dc.l .lmr_len_07
    dc.l .lmr_len_08
    dc.l .lmr_len_09
    dc.l .lmr_len_0A
    dc.l .lmr_len_0B
    dc.l .lmr_len_0C
    dc.l .lmr_len_0D
    dc.l .lmr_len_0E
    dc.l .lmr_len_0F
    dc.l .lmr_len_10
    dc.l .lmr_len_11
    dc.l .lmr_len_12
    dc.l .lmr_len_13
    dc.l .lmr_len_14
    dc.l .lmr_len_15
    dc.l .lmr_len_16
    dc.l .lmr_len_17
    dc.l .lmr_len_18
    dc.l .lmr_len_19
    dc.l .lmr_len_1A
    dc.l .lmr_len_1B
    dc.l .lmr_len_1C
    dc.l .lmr_len_1D
    dc.l .lmr_len_1E
    dc.l .lmr_len_1F
    dc.l .lmr_len_20
    dc.l .lmr_len_21
    dc.l .lmr_len_22
    dc.l .lmr_len_23
    dc.l .lmr_len_24
    dc.l .lmr_len_25
    dc.l .lmr_len_26
    dc.l .lmr_len_27
    dc.l .lmr_len_28
    dc.l .lmr_len_29
    dc.l .lmr_len_2A
    dc.l .lmr_len_2B
    dc.l .lmr_len_2C
    dc.l .lmr_len_2D
    dc.l .lmr_len_2E
    dc.l .lmr_len_2F
    dc.l .lmr_len_30
    dc.l .lmr_len_31
    dc.l .lmr_len_32
    dc.l .lmr_len_33
    dc.l .lmr_len_34
    dc.l .lmr_len_35
    dc.l .lmr_len_36
    dc.l .lmr_len_37
    dc.l .lmr_len_38
    dc.l .lmr_len_39
    dc.l .lmr_len_3A
    dc.l .lmr_len_3B
    dc.l .lmr_len_3C
    dc.l .lmr_len_3D
    dc.l .lmr_len_3E
    dc.l .lmr_len_3F
    dc.l .lmr_len_40
    dc.l .lmr_len_41
    dc.l .lmr_len_42
    dc.l .lmr_len_43
    dc.l .lmr_len_44
    dc.l .lmr_len_45
    dc.l .lmr_len_46
    dc.l .lmr_len_47
    dc.l .lmr_len_48
    dc.l .lmr_len_49
    dc.l .lmr_len_4A
    dc.l .lmr_len_4B
    dc.l .lmr_len_4C
    dc.l .lmr_len_4D
    dc.l .lmr_len_4E
    dc.l .lmr_len_4F
    dc.l .lmr_len_50
    dc.l .lmr_len_51
    dc.l .lmr_len_52
    dc.l .lmr_len_53
    dc.l .lmr_len_54
    dc.l .lmr_len_55
    dc.l .lmr_len_56
    dc.l .lmr_len_57
    dc.l .lmr_len_58
    dc.l .lmr_len_59
    dc.l .lmr_len_5A
    dc.l .lmr_len_5B
    dc.l .lmr_len_5C
    dc.l .lmr_len_5D
    dc.l .lmr_len_5E
    dc.l .lmr_len_5F
    dc.l .lmr_len_60
    dc.l .lmr_len_61
    dc.l .lmr_len_62
    dc.l .lmr_len_63
    dc.l .lmr_len_64
    dc.l .lmr_len_65
    dc.l .lmr_len_66
    dc.l .lmr_len_67
    dc.l .lmr_len_68
    dc.l .lmr_len_69
    dc.l .lmr_len_6A
    dc.l .lmr_len_6B
    dc.l .lmr_len_6C
    dc.l .lmr_len_6D
    dc.l .lmr_len_6E
    dc.l .lmr_len_6F
    dc.l .lmr_len_70
    dc.l .lmr_len_71
    dc.l .lmr_len_72
    dc.l .lmr_len_73
    dc.l .lmr_len_74
    dc.l .lmr_len_75
    dc.l .lmr_len_76
    dc.l .lmr_len_77
    dc.l .lmr_len_78
    dc.l .lmr_len_79
    dc.l .lmr_len_7A
    dc.l .lmr_len_7B
    dc.l .lmr_len_7C
    dc.l .lmr_len_7D
    dc.l .lmr_len_7E
    dc.l .lmr_len_7F
    dc.l .lmr_len_80
    dc.l .lmr_len_81
    dc.l .lmr_len_82
    dc.l .lmr_len_83
    dc.l .lmr_len_84
    dc.l .lmr_len_85
    dc.l .lmr_len_86
    dc.l .lmr_len_87
    dc.l .lmr_len_88
    dc.l .lmr_len_89
    dc.l .lmr_len_8A
    dc.l .lmr_len_8B
    dc.l .lmr_len_8C
    dc.l .lmr_len_8D
    dc.l .lmr_len_8E
    dc.l .lmr_len_8F
    dc.l .lmr_len_90
    dc.l .lmr_len_91
    dc.l .lmr_len_92
    dc.l .lmr_len_93
    dc.l .lmr_len_94
    dc.l .lmr_len_95
    dc.l .lmr_len_96
    dc.l .lmr_len_97
    dc.l .lmr_len_98
    dc.l .lmr_len_99
    dc.l .lmr_len_9A
    dc.l .lmr_len_9B
    dc.l .lmr_len_9C
    dc.l .lmr_len_9D
    dc.l .lmr_len_9E
    dc.l .lmr_len_9F
    dc.l .lmr_len_A0
    dc.l .lmr_len_A1
    dc.l .lmr_len_A2
    dc.l .lmr_len_A3
    dc.l .lmr_len_A4
    dc.l .lmr_len_A5
    dc.l .lmr_len_A6
    dc.l .lmr_len_A7
    dc.l .lmr_len_A8
    dc.l .lmr_len_A9
    dc.l .lmr_len_AA
    dc.l .lmr_len_AB
    dc.l .lmr_len_AC
    dc.l .lmr_len_AD
    dc.l .lmr_len_AE
    dc.l .lmr_len_AF
    dc.l .lmr_len_B0
    dc.l .lmr_len_B1
    dc.l .lmr_len_B2
    dc.l .lmr_len_B3
    dc.l .lmr_len_B4
    dc.l .lmr_len_B5
    dc.l .lmr_len_B6
    dc.l .lmr_len_B7
    dc.l .lmr_len_B8
    dc.l .lmr_len_B9
    dc.l .lmr_len_BA
    dc.l .lmr_len_BB
    dc.l .lmr_len_BC
    dc.l .lmr_len_BD
    dc.l .lmr_len_BE
    dc.l .lmr_len_BF
    dc.l .lmr_len_C0
    dc.l .lmr_len_C1
    dc.l .lmr_len_C2
    dc.l .lmr_len_C3
    dc.l .lmr_len_C4
    dc.l .lmr_len_C5
    dc.l .lmr_len_C6
    dc.l .lmr_len_C7
    dc.l .lmr_len_C8
    dc.l .lmr_len_C9
    dc.l .lmr_len_CA
    dc.l .lmr_len_CB
    dc.l .lmr_len_CC
    dc.l .lmr_len_CD
    dc.l .lmr_len_CE
    dc.l .lmr_len_CF
    dc.l .lmr_len_D0
    dc.l .lmr_len_D1
    dc.l .lmr_len_D2
    dc.l .lmr_len_D3
    dc.l .lmr_len_D4
    dc.l .lmr_len_D5
    dc.l .lmr_len_D6
    dc.l .lmr_len_D7
    dc.l .lmr_len_D8
    dc.l .lmr_len_D9
    dc.l .lmr_len_DA
    dc.l .lmr_len_DB
    dc.l .lmr_len_DC
    dc.l .lmr_len_DD
    dc.l .lmr_len_DE
    dc.l .lmr_len_DF
    dc.l .lmr_len_E0
    dc.l .lmr_len_E1
    dc.l .lmr_len_E2
    dc.l .lmr_len_E3
    dc.l .lmr_len_E4
    dc.l .lmr_len_E5
    dc.l .lmr_len_E6
    dc.l .lmr_len_E7
    dc.l .lmr_len_E8
    dc.l .lmr_len_E9
    dc.l .lmr_len_EA
    dc.l .lmr_len_EB
    dc.l .lmr_len_EC
    dc.l .lmr_len_ED
    dc.l .lmr_len_EE
    dc.l .lmr_len_EF
    dc.l .lmr_len_F0
    dc.l .lmr_len_F1
    dc.l .lmr_len_F2
    dc.l .lmr_len_F3
    dc.l .lmr_len_F4
    dc.l .lmr_len_F5
    dc.l .lmr_len_F6
    dc.l .lmr_len_F7
    dc.l .lmr_len_F8
    dc.l .lmr_len_F9
    dc.l .lmr_len_FA
    dc.l .lmr_len_FB
    dc.l .lmr_len_FC
    dc.l .lmr_len_FD
    dc.l .lmr_len_FE
    dc.l .lmr_len_FF


.litE_mat1:
    move.l  (a0)+,(a1)+
.litC_mat1:
    move.l  (a0)+,(a1)+
.litA_mat1:
    move.l  (a0)+,(a1)+
.lit8_mat1:
    move.l  (a0)+,(a1)+
.lit6_mat1:
    move.l  (a0)+,(a1)+
.lit4_mat1:
    move.l  (a0)+,(a1)+
.lit2_mat1:
    move.l  (a0)+,(a1)+
.lit0_mat1:
    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litF_mat1:
    move.l  (a0)+,(a1)+
.litD_mat1:
    move.l  (a0)+,(a1)+
.litB_mat1:
    move.l  (a0)+,(a1)+
.lit9_mat1:
    move.l  (a0)+,(a1)+
.lit7_mat1:
    move.l  (a0)+,(a1)+
.lit5_mat1:
    move.l  (a0)+,(a1)+
.lit3_mat1:
    move.l  (a0)+,(a1)+
.lit1_mat1:
    move.w  (a0)+,(a1)+

    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litE_mat2:
    move.l  (a0)+,(a1)+
.litC_mat2:
    move.l  (a0)+,(a1)+
.litA_mat2:
    move.l  (a0)+,(a1)+
.lit8_mat2:
    move.l  (a0)+,(a1)+
.lit6_mat2:
    move.l  (a0)+,(a1)+
.lit4_mat2:
    move.l  (a0)+,(a1)+
.lit2_mat2:
    move.l  (a0)+,(a1)+
.lit0_mat2:
    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litF_mat2:
    move.l  (a0)+,(a1)+
.litD_mat2:
    move.l  (a0)+,(a1)+
.litB_mat2:
    move.l  (a0)+,(a1)+
.lit9_mat2:
    move.l  (a0)+,(a1)+
.lit7_mat2:
    move.l  (a0)+,(a1)+
.lit5_mat2:
    move.l  (a0)+,(a1)+
.lit3_mat2:
    move.l  (a0)+,(a1)+
.lit1_mat2:
    move.w  (a0)+,(a1)+

    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litE_mat3:
    move.l  (a0)+,(a1)+
.litC_mat3:
    move.l  (a0)+,(a1)+
.litA_mat3:
    move.l  (a0)+,(a1)+
.lit8_mat3:
    move.l  (a0)+,(a1)+
.lit6_mat3:
    move.l  (a0)+,(a1)+
.lit4_mat3:
    move.l  (a0)+,(a1)+
.lit2_mat3:
    move.l  (a0)+,(a1)+
.lit0_mat3:
    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litF_mat3:
    move.l  (a0)+,(a1)+
.litD_mat3:
    move.l  (a0)+,(a1)+
.litB_mat3:
    move.l  (a0)+,(a1)+
.lit9_mat3:
    move.l  (a0)+,(a1)+
.lit7_mat3:
    move.l  (a0)+,(a1)+
.lit5_mat3:
    move.l  (a0)+,(a1)+
.lit3_mat3:
    move.l  (a0)+,(a1)+
.lit1_mat3:
    move.w  (a0)+,(a1)+

    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litE_mat4:
    move.l  (a0)+,(a1)+
.litC_mat4:
    move.l  (a0)+,(a1)+
.litA_mat4:
    move.l  (a0)+,(a1)+
.lit8_mat4:
    move.l  (a0)+,(a1)+
.lit6_mat4:
    move.l  (a0)+,(a1)+
.lit4_mat4:
    move.l  (a0)+,(a1)+
.lit2_mat4:
    move.l  (a0)+,(a1)+
.lit0_mat4:
    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litF_mat4:
    move.l  (a0)+,(a1)+
.litD_mat4:
    move.l  (a0)+,(a1)+
.litB_mat4:
    move.l  (a0)+,(a1)+
.lit9_mat4:
    move.l  (a0)+,(a1)+
.lit7_mat4:
    move.l  (a0)+,(a1)+
.lit5_mat4:
    move.l  (a0)+,(a1)+
.lit3_mat4:
    move.l  (a0)+,(a1)+
.lit1_mat4:
    move.w  (a0)+,(a1)+

    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litE_mat5:
    move.l  (a0)+,(a1)+
.litC_mat5:
    move.l  (a0)+,(a1)+
.litA_mat5:
    move.l  (a0)+,(a1)+
.lit8_mat5:
    move.l  (a0)+,(a1)+
.lit6_mat5:
    move.l  (a0)+,(a1)+
.lit4_mat5:
    move.l  (a0)+,(a1)+
.lit2_mat5:
    move.l  (a0)+,(a1)+
.lit0_mat5:
    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litF_mat5:
    move.l  (a0)+,(a1)+
.litD_mat5:
    move.l  (a0)+,(a1)+
.litB_mat5:
    move.l  (a0)+,(a1)+
.lit9_mat5:
    move.l  (a0)+,(a1)+
.lit7_mat5:
    move.l  (a0)+,(a1)+
.lit5_mat5:
    move.l  (a0)+,(a1)+
.lit3_mat5:
    move.l  (a0)+,(a1)+
.lit1_mat5:
    move.w  (a0)+,(a1)+

    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litE_mat6:
    move.l  (a0)+,(a1)+
.litC_mat6:
    move.l  (a0)+,(a1)+
.litA_mat6:
    move.l  (a0)+,(a1)+
.lit8_mat6:
    move.l  (a0)+,(a1)+
.lit6_mat6:
    move.l  (a0)+,(a1)+
.lit4_mat6:
    move.l  (a0)+,(a1)+
.lit2_mat6:
    move.l  (a0)+,(a1)+
.lit0_mat6:
    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litF_mat6:
    move.l  (a0)+,(a1)+
.litD_mat6:
    move.l  (a0)+,(a1)+
.litB_mat6:
    move.l  (a0)+,(a1)+
.lit9_mat6:
    move.l  (a0)+,(a1)+
.lit7_mat6:
    move.l  (a0)+,(a1)+
.lit5_mat6:
    move.l  (a0)+,(a1)+
.lit3_mat6:
    move.l  (a0)+,(a1)+
.lit1_mat6:
    move.w  (a0)+,(a1)+

    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litE_mat7:
    move.l  (a0)+,(a1)+
.litC_mat7:
    move.l  (a0)+,(a1)+
.litA_mat7:
    move.l  (a0)+,(a1)+
.lit8_mat7:
    move.l  (a0)+,(a1)+
.lit6_mat7:
    move.l  (a0)+,(a1)+
.lit4_mat7:
    move.l  (a0)+,(a1)+
.lit2_mat7:
    move.l  (a0)+,(a1)+
.lit0_mat7:
    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litF_mat7:
    move.l  (a0)+,(a1)+
.litD_mat7:
    move.l  (a0)+,(a1)+
.litB_mat7:
    move.l  (a0)+,(a1)+
.lit9_mat7:
    move.l  (a0)+,(a1)+
.lit7_mat7:
    move.l  (a0)+,(a1)+
.lit5_mat7:
    move.l  (a0)+,(a1)+
.lit3_mat7:
    move.l  (a0)+,(a1)+
.lit1_mat7:
    move.w  (a0)+,(a1)+

    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litE_mat8:
    move.l  (a0)+,(a1)+
.litC_mat8:
    move.l  (a0)+,(a1)+
.litA_mat8:
    move.l  (a0)+,(a1)+
.lit8_mat8:
    move.l  (a0)+,(a1)+
.lit6_mat8:
    move.l  (a0)+,(a1)+
.lit4_mat8:
    move.l  (a0)+,(a1)+
.lit2_mat8:
    move.l  (a0)+,(a1)+
.lit0_mat8:
    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litF_mat8:
    move.l  (a0)+,(a1)+
.litD_mat8:
    move.l  (a0)+,(a1)+
.litB_mat8:
    move.l  (a0)+,(a1)+
.lit9_mat8:
    move.l  (a0)+,(a1)+
.lit7_mat8:
    move.l  (a0)+,(a1)+
.lit5_mat8:
    move.l  (a0)+,(a1)+
.lit3_mat8:
    move.l  (a0)+,(a1)+
.lit1_mat8:
    move.w  (a0)+,(a1)+

    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litE_mat9:
    move.l  (a0)+,(a1)+
.litC_mat9:
    move.l  (a0)+,(a1)+
.litA_mat9:
    move.l  (a0)+,(a1)+
.lit8_mat9:
    move.l  (a0)+,(a1)+
.lit6_mat9:
    move.l  (a0)+,(a1)+
.lit4_mat9:
    move.l  (a0)+,(a1)+
.lit2_mat9:
    move.l  (a0)+,(a1)+
.lit0_mat9:
    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litF_mat9:
    move.l  (a0)+,(a1)+
.litD_mat9:
    move.l  (a0)+,(a1)+
.litB_mat9:
    move.l  (a0)+,(a1)+
.lit9_mat9:
    move.l  (a0)+,(a1)+
.lit7_mat9:
    move.l  (a0)+,(a1)+
.lit5_mat9:
    move.l  (a0)+,(a1)+
.lit3_mat9:
    move.l  (a0)+,(a1)+
.lit1_mat9:
    move.w  (a0)+,(a1)+

    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litE_matA:
    move.l  (a0)+,(a1)+
.litC_matA:
    move.l  (a0)+,(a1)+
.litA_matA:
    move.l  (a0)+,(a1)+
.lit8_matA:
    move.l  (a0)+,(a1)+
.lit6_matA:
    move.l  (a0)+,(a1)+
.lit4_matA:
    move.l  (a0)+,(a1)+
.lit2_matA:
    move.l  (a0)+,(a1)+
.lit0_matA:
    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litF_matA:
    move.l  (a0)+,(a1)+
.litD_matA:
    move.l  (a0)+,(a1)+
.litB_matA:
    move.l  (a0)+,(a1)+
.lit9_matA:
    move.l  (a0)+,(a1)+
.lit7_matA:
    move.l  (a0)+,(a1)+
.lit5_matA:
    move.l  (a0)+,(a1)+
.lit3_matA:
    move.l  (a0)+,(a1)+
.lit1_matA:
    move.w  (a0)+,(a1)+

    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litE_matB:
    move.l  (a0)+,(a1)+
.litC_matB:
    move.l  (a0)+,(a1)+
.litA_matB:
    move.l  (a0)+,(a1)+
.lit8_matB:
    move.l  (a0)+,(a1)+
.lit6_matB:
    move.l  (a0)+,(a1)+
.lit4_matB:
    move.l  (a0)+,(a1)+
.lit2_matB:
    move.l  (a0)+,(a1)+
.lit0_matB:
    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litF_matB:
    move.l  (a0)+,(a1)+
.litD_matB:
    move.l  (a0)+,(a1)+
.litB_matB:
    move.l  (a0)+,(a1)+
.lit9_matB:
    move.l  (a0)+,(a1)+
.lit7_matB:
    move.l  (a0)+,(a1)+
.lit5_matB:
    move.l  (a0)+,(a1)+
.lit3_matB:
    move.l  (a0)+,(a1)+
.lit1_matB:
    move.w  (a0)+,(a1)+

    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litE_matC:
    move.l  (a0)+,(a1)+
.litC_matC:
    move.l  (a0)+,(a1)+
.litA_matC:
    move.l  (a0)+,(a1)+
.lit8_matC:
    move.l  (a0)+,(a1)+
.lit6_matC:
    move.l  (a0)+,(a1)+
.lit4_matC:
    move.l  (a0)+,(a1)+
.lit2_matC:
    move.l  (a0)+,(a1)+
.lit0_matC:
    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litF_matC:
    move.l  (a0)+,(a1)+
.litD_matC:
    move.l  (a0)+,(a1)+
.litB_matC:
    move.l  (a0)+,(a1)+
.lit9_matC:
    move.l  (a0)+,(a1)+
.lit7_matC:
    move.l  (a0)+,(a1)+
.lit5_matC:
    move.l  (a0)+,(a1)+
.lit3_matC:
    move.l  (a0)+,(a1)+
.lit1_matC:
    move.w  (a0)+,(a1)+

    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litE_matD:
    move.l  (a0)+,(a1)+
.litC_matD:
    move.l  (a0)+,(a1)+
.litA_matD:
    move.l  (a0)+,(a1)+
.lit8_matD:
    move.l  (a0)+,(a1)+
.lit6_matD:
    move.l  (a0)+,(a1)+
.lit4_matD:
    move.l  (a0)+,(a1)+
.lit2_matD:
    move.l  (a0)+,(a1)+
.lit0_matD:
    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litF_matD:
    move.l  (a0)+,(a1)+
.litD_matD:
    move.l  (a0)+,(a1)+
.litB_matD:
    move.l  (a0)+,(a1)+
.lit9_matD:
    move.l  (a0)+,(a1)+
.lit7_matD:
    move.l  (a0)+,(a1)+
.lit5_matD:
    move.l  (a0)+,(a1)+
.lit3_matD:
    move.l  (a0)+,(a1)+
.lit1_matD:
    move.w  (a0)+,(a1)+

    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litE_matE:
    move.l  (a0)+,(a1)+
.litC_matE:
    move.l  (a0)+,(a1)+
.litA_matE:
    move.l  (a0)+,(a1)+
.lit8_matE:
    move.l  (a0)+,(a1)+
.lit6_matE:
    move.l  (a0)+,(a1)+
.lit4_matE:
    move.l  (a0)+,(a1)+
.lit2_matE:
    move.l  (a0)+,(a1)+
.lit0_matE:
    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litF_matE:
    move.l  (a0)+,(a1)+
.litD_matE:
    move.l  (a0)+,(a1)+
.litB_matE:
    move.l  (a0)+,(a1)+
.lit9_matE:
    move.l  (a0)+,(a1)+
.lit7_matE:
    move.l  (a0)+,(a1)+
.lit5_matE:
    move.l  (a0)+,(a1)+
.lit3_matE:
    move.l  (a0)+,(a1)+
.lit1_matE:
    move.w  (a0)+,(a1)+

    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litE_matF:
    move.l  (a0)+,(a1)+
.litC_matF:
    move.l  (a0)+,(a1)+
.litA_matF:
    move.l  (a0)+,(a1)+
.lit8_matF:
    move.l  (a0)+,(a1)+
.lit6_matF:
    move.l  (a0)+,(a1)+
.lit4_matF:
    move.l  (a0)+,(a1)+
.lit2_matF:
    move.l  (a0)+,(a1)+
.lit0_matF:
    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.litF_matF:
    move.l  (a0)+,(a1)+
.litD_matF:
    move.l  (a0)+,(a1)+
.litB_matF:
    move.l  (a0)+,(a1)+
.lit9_matF:
    move.l  (a0)+,(a1)+
.lit7_matF:
    move.l  (a0)+,(a1)+
.lit5_matF:
    move.l  (a0)+,(a1)+
.lit3_matF:
    move.l  (a0)+,(a1)+
.lit1_matF:
    move.w  (a0)+,(a1)+

    add.w   d1,d1
    neg.w   d1
    lea     -2(a1,d1.w),a2       ; a2 = dst - ((match offset + 1) * 2)

    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    move.w  (a2)+,(a1)+
    moveq   #0,d1
    jmp     (a3)

.done:
    move.w  (a0)+,d0              ; need to copy a last byte ?
    bpl.s   .no_byte

    move.b  d0,(a1)+              ; copy last byte
.no_byte:

    move.l  a1,d0
    sub.l   20(sp),d0             ; return op - dest

    movem.l (sp)+,a2-a4
    rts
