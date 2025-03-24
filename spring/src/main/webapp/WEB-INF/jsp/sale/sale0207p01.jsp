<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비원가관리 > null > 장비원가관리상세
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-08-02 15:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
        var auiGridFOB;
        var auiGridCIF;
        var auiGridMV;
        var auiGridBA;
        var auiGridNEW;
        var auiGridMA;
        var mvSubTotal;
        var cifSubTotal;

        const commonGridPros = {
            rowIdField: "_$uid",
            height: 158,
            editable: true,
            showStateColumn: true,
            enableSorting : false,
        }

        const commonGridProsWithFooter = {
            rowIdField: "_$uid",
            height: 218,
            editable: true,
            showStateColumn: true,
            showFooter: true, // footer 설정
            footerRowCount: 2, // footer 출력 행 개수 설정
            enableSorting : false,
        }

		$(document).ready(function() {
            fnInit();
		});

        function fnInit() {
            createAUIGridFOB();
            createAUIGridCIF();
            createAUIGridMV();
            createAUIGridBA();
            createAUIGridNEW();
            createAUIGridMA();

            if ("${item.money_unit_cd}" == "") {
                alert("화폐단위를 장비코드관리에서 추가해주세요!");
                var param = {
                    machine_plant_seq : "${item.machine_plant_seq}"
                };
                $M.goNextPage('/sale/sale0206p01', $M.toGetParam(param), {popupStatus : ""});
                fnClose();
                return false;
            }
            $("input").not("#apply_er_price, #agree_price, #review_price").blur(fnApplyErPrice);

            // 예약원가일 경우 기본값 예약 체크
            if ("${show_reserve_yn}" == 'Y') {
                $('#reserve_yn').prop('checked', true);
                $('#reserve_yn').val("Y");
            }

            fnApplyErPrice();
            goReservePopup();
        }

		// 환율적용
		function fnApplyErPrice() {
            fnChangeCif();
			fnChangeAdjust();
		}

		// 1. FOB
        // 사용안함
		function fnChangeFob() {
			// FOB
			var fob_price = $M.toNum($M.getValue("fob_price"));
			// 가격조정항목1
			var fob_adjust_1_price = $M.toNum($M.getValue("fob_adjust_1_price"));
			// 가격조정항목2
			var fob_adjust_2_price = $M.toNum($M.getValue("fob_adjust_2_price"));
			// 가격조정항목3
			var fob_adjust_3_price = $M.toNum($M.getValue("fob_adjust_3_price"));
			// 가격조정항목4
			var fob_adjust_4_price = $M.toNum($M.getValue("fob_adjust_4_price"));
			// 소계
			var fob_sub_amt = fob_price+fob_adjust_1_price+fob_adjust_2_price+fob_adjust_3_price+fob_adjust_4_price;
			// 가격조정항목5
			var fob_adjust_5_price = $M.toNum($M.getValue("fob_adjust_5_price"));
			// 가격조정항목6
			var fob_adjust_6_price = $M.toNum($M.getValue("fob_adjust_6_price"));
			// FOB합계
			var fob_total_amt = fob_sub_amt + fob_adjust_5_price + fob_adjust_6_price;

			$M.setValue("fob_sub_amt", fob_sub_amt);
			$M.setValue("fob_total_amt", fob_total_amt);

			fnChangeCif();
		}

		// 2. CIF
		function fnChangeCif() {
			// FOB 합계
			var fob_total_amt = parseInt(AUIGrid.getFooterData(auiGridFOB)[0][1].value);
            $M.setValue("fob_total_amt", fob_total_amt);
			// Interest cost(%)
			var cif_interest_rate = $M.toNum($M.getValue("cif_interest_rate"));
			// Interest cost amt
			var cif_interest_amt = fob_total_amt * (cif_interest_rate / 100);

			// CIF Charge
			// var cif_charge = $M.toNum($M.getValue("cif_charge"));
			// 추가항목  CIF 추가항목1
			// var cif_add_1_price = $M.toNum($M.getValue("cif_add_1_price"));

			cif_interest_amt = Math.ceil(cif_interest_amt);

            // CIF 그리드 소계 계산
            cifSubTotal = calcSum(auiGridCIF);

			// CIF 소계(JYP) : CIF 그리드 전체금액 + FOB 합계 + CIF Interest Cost
			var cif_total_amt = fob_total_amt + cif_interest_amt + cifSubTotal;
			// 적용환율
			var apply_er_price = $M.toNum($M.getValue("apply_er_price"));
			// CIF 소계(KRW)
			var cif_krw_amt = Math.ceil(cif_total_amt * apply_er_price);

			var param = {
				cif_interest_amt : cif_interest_amt,
				cif_total_amt : cif_total_amt,
				cif_krw_amt : cif_krw_amt,
			}
			$M.setValue(param);

			fnChangeMv();
		}

		// 3. 통관
		function fnChangeMv() {
			// 통관비 %
			var mv_pass_rate = $M.toNum($M.getValue("mv_pass_rate"));
			// CIF KRW
			var cif_krw_amt = $M.toNum($M.getValue("cif_krw_amt"));

			// 통관비 AMT 계산 = CIF KRW * 통관비 %
			var mv_pass_amt = cif_krw_amt * (mv_pass_rate / 100);
			mv_pass_amt = Math.ceil(mv_pass_amt);

			// 내륙운반비(Container)
			// var mv_move_price = $M.toNum($M.getValue("mv_move_price"));
			// 추가항목 1
			// var mv_add_1_price = $M.toNum($M.getValue("mv_add_1_price"));

            // 3번 그리드 총금액 계산
            mvSubTotal = calcSum(auiGridMV);

			// 통관/내륙운반 소계 계산 = 통관비 + 3 통관 그리드 합계
			var mv_total_amt = mv_pass_amt + $M.toNum(mvSubTotal);

			// 1+2+3 합계
			var group_1_total_amt = cif_krw_amt + mv_total_amt;

			var param = {
				mv_pass_amt : mv_pass_amt,
				mv_total_amt : mv_total_amt,
				group_1_total_amt : group_1_total_amt
			}
			$M.setValue(param);

			fnChangeBa();
		}

		// 최저판매가변경
		function fnChangeMinSalePrice() {
			fnChangeBa();
			fnChangeAdjust();
		}

		// 4. 기본지급품
		function fnChangeBa() {
			// 대버켓
			// var ba_big_bucket_price = $M.toNum($M.getValue("ba_big_bucket_price"));
			// 중버켓
			// var ba_mid_bucket_price = $M.toNum($M.getValue("ba_mid_bucket_price"));
			// 소버켓
			// var ba_small_bucket_price = $M.toNum($M.getValue("ba_small_bucket_price"));
			// 자동링크
			// var ba_auto_link_price = $M.toNum($M.getValue("ba_auto_link_price"));
			// 기본지급품
			// var ba_base_item_price = $M.toNum($M.getValue("ba_base_item_price"));
			// 필터세트
			// var ba_filter_price = $M.toNum($M.getValue("ba_filter_price"));

			// 라디오
			// var ba_radio_price = $M.toNum($M.getValue("ba_radio_price"));
			// 캐노피 절단비용
			// var ba_canopy_cut_price = $M.toNum($M.getValue("ba_canopy_cut_price"));
			// 운반비(사업장-고객)
			// var ba_move_price = $M.toNum($M.getValue("ba_move_price"));
			// 서비스DI
			// var ba_svc_di_price = $M.toNum($M.getValue("ba_svc_di_price"));
			// 추가항목1,2는 계산에 넣지않음(엑셀참고)
			// var ba_add_1_price = $M.toNum($M.getValue("ba_add_1_price"));
			// var ba_add_2_price = $M.toNum($M.getValue("ba_add_2_price"));

			// 기본지급품소계 (그리드에서 계산)
            var ba_total_amt = calcSum(auiGridBA);
            $M.setValue("ba_total_amt", $M.toNum(ba_total_amt));
			// var ba_total_amt = ba_big_bucket_price + ba_mid_bucket_price + ba_small_bucket_price
			// 				 + ba_auto_link_price + ba_base_item_price + ba_filter_price + mng_svc_amt
			// 				 + ba_radio_price + ba_canopy_cut_price + ba_move_price + ba_svc_di_price
			// 				 + ba_add_1_price + ba_add_2_price;
			// var mv_total_amt = $M.toNum($M.getValue("mv_total_amt"));

			// 1+2+3+4 합계 계산
			var group_2_total_amt = $M.toNum($M.getValue("group_1_total_amt")) + ba_total_amt;

            AUIGrid.update(auiGridBA);

			$M.setValue("group_2_total_amt", group_2_total_amt);


            fnChangeMng();
		}

		// 5. 일반관리비
		function fnChangeMng() {
			// 최저판매가
			var min_sale_price = $M.toNum($M.getValue("min_sale_price"));

			// 일반관리비(%)
			var mng_mng_rate = $M.toNum($M.getValue("mng_mng_rate"));

			// 일반관리비 계산
			var mng_mng_amt = min_sale_price * (mng_mng_rate / 100);

			// 조선왕요청, 프로모션가(본사)에 금액이 기재되어 있으면 최저판매가가 아닌 프로모션가 기준으로 계산필요
			var pro_adjust_amt =  $M.toNum($M.getValue("pro_adjust_amt"));

			if (pro_adjust_amt != 0) {
				var basePromotion = min_sale_price - pro_adjust_amt;
				mng_mng_amt = basePromotion * (mng_mng_rate / 100);
			}

			mng_mng_amt = Math.ceil(mng_mng_amt);

            // 서비스비용%
            var mng_svc_rate = $M.toNum($M.getValue("mng_svc_rate"));

            // 관리서비스금액 계산
            var mng_svc_amt = min_sale_price * (mng_svc_rate / 100);
            // 조선왕요청, 프로모션가(본사)에 금액이 기재되어 있으면 최저판매가가 아닌 프로모션가 기준으로 계산필요
            if (pro_adjust_amt != 0) {
                var basePromotion = min_sale_price - pro_adjust_amt;
                mng_svc_amt = basePromotion * (mng_svc_rate / 100);
            }
            mng_svc_amt = Math.ceil(mng_svc_amt);

            // 관리비소계 계산 = 일반관리비 + 서비스금액
            var mng_total_amt = mng_mng_amt + mng_svc_amt;

            // 1+2+3+4+5 합계 계산 = 1+2+3+4 + 관리비소계
            var group_3_total_amt = $M.toNum($M.getValue("group_2_total_amt")) + mng_total_amt;

			var param = {
                mng_mng_amt : mng_mng_amt,
                mng_total_amt : mng_total_amt,
				group_3_total_amt : group_3_total_amt,
                mng_svc_amt : mng_svc_amt,
			}
			$M.setValue(param);

            fnChangeNew();
		}

        // 6. 신장비도입비용
        function fnChangeNew() {

            // 신장비도입 소계 계산 - 6번 그리드 금액 총합계
            var newTotalAmt = calcSum(auiGridNEW)

            // 신장비도입 분배 계산
            var newDivOneAmt = 0;
            var newDivCnt = $M.toNum($M.getValue("new_div_cnt"));
            if (newDivCnt != 0) {
                newDivOneAmt = Math.ceil(newTotalAmt / newDivCnt);
            }

            // 1+2+3+4+5+6 합계 계산 = 1+2+3+4+5 합계 + (신장비도입 소계 / 분배수)
            var group4TotalAmt = $M.toNum($M.getValue("group_3_total_amt")) + newDivOneAmt;

            var param = {
                "new_total_amt" : newTotalAmt,
                "new_div_one_amt" : newDivOneAmt,
                "group_4_total_amt" : group4TotalAmt
            }
            $M.setValue(param);

            fnChangeMaAgency();
        }

        // 7. 마진(대리점)
		function fnChangeMaAgency() {

			// 대리점수수료
			// var ma_agency_margin_amt = $M.toNum($M.getValue("ma_agency_margin_amt"));
			// 대리점 인센티브
			// var ma_agency_incen_amt = $M.toNum($M.getValue("ma_agency_incen_amt"));
			// 대리점 추가항목1
			// var ma_agency_add_1_price = $M.toNum($M.getValue("ma_agency_add_1_price"));
			// 대리점 추가항목2
			// var ma_agency_add_2_price = $M.toNum($M.getValue("ma_agency_add_2_price"));

            // 7번 그리드 (대리점마진) 소계
            $M.setValue("ma_total_amt", calcSum(auiGridMA));

            // 1+2+3+4+5+6+7 총원가 계산 = 1+2+3+4+5+6 합계 + 마진 그리드 소계
            var group_5_total_amt = $M.toNum($M.getValue("group_4_total_amt")) + $M.toNum($M.getValue("ma_total_amt"));

            AUIGrid.update(auiGridMA);

			$M.setValue("group_5_total_amt", group_5_total_amt);

            fnChangeMaYk();
		}

        // 8 마진(YK)
        function fnChangeMaYk() {

            // 1+2+3+4+5+6+7 총원가
            var group_5_total_amt = $M.toNum($M.getValue("group_5_total_amt"));

            // 최저판매가
            var min_sale_price = $M.toNum($M.getValue("min_sale_price"));

            // YK마진금액 (YK마진추가항목1은 계산에 참여하지않음)
            // 프로모션조정 있으면 또 빼라고 함 조선왕한테 확인받음 9.2
            var pro_adjust_amt =  $M.toNum($M.getValue("pro_adjust_amt"));
            var ma_yk_margin_amt = min_sale_price - group_5_total_amt - pro_adjust_amt;

            // YK마진율
            var ma_yk_margin_rate = 0;
            if (min_sale_price != 0) {
                ma_yk_margin_rate = (ma_yk_margin_amt / min_sale_price) * 100;
                ma_yk_margin_rate = Math.ceil(ma_yk_margin_rate);
            }

            var param = {
                ma_yk_margin_amt : ma_yk_margin_amt,
                ma_yk_margin_rate : ma_yk_margin_rate
            }
            $M.setValue(param);
        }

		// 대리점공급가, 리스트가, 프로모션판매가 변경
		function fnChangeAdjust() {
			// 최저판매가
			var min_sale_price = $M.toNum($M.getValue("min_sale_price"));

			// 대리점공급가조정
			var agency_adjust_amt = $M.toNum($M.getValue("agency_adjust_amt"));

			// 대리점최저공급가
			var agency_min_sale_price = min_sale_price - agency_adjust_amt;

			// 리스트가조정
			var list_adjust_amt = $M.toNum($M.getValue("list_adjust_amt"));

			// 판매가격(리스트)
			var list_sale_price = min_sale_price + list_adjust_amt;

			// 프로모션조정
			var pro_adjust_amt = $M.toNum($M.getValue("pro_adjust_amt"));

			// 조선왕대리요청, 프로모션가 조정값 없으면 프로모션가 0원으로처리
			var base_pro_sale_price = 0;
			var agency_pro_sale_price = 0;
			if (pro_adjust_amt != 0) {
				// 프로모션가(본사)
				base_pro_sale_price = min_sale_price - pro_adjust_amt;

				// 프로모션가(대리점)
				agency_pro_sale_price = agency_min_sale_price - pro_adjust_amt;
			}

            // 작성전결가
            var write_price = $M.toNum($M.getValue("write_price"));

            // 할인한도 = 최저판매가 - 작성전결가
            var max_dc_price = min_sale_price - write_price;

			var param = {
				agency_min_sale_price : agency_min_sale_price,
				list_sale_price : list_sale_price,
				agency_pro_sale_price : agency_pro_sale_price,
				base_pro_sale_price : base_pro_sale_price,
                max_dc_price : max_dc_price,
			}

			$M.setValue(param);
		}

		// 장비조회
		function goMachineCost(row) {
			setTimeout(function(){
				if (row.machine_plant_seq == "${inputParam.machine_plant_seq}") {
					alert("다른 장비를 선택해주세요.");
					return false;
				}
				if (confirm(row.machine_name+" 장비의 원가를 조회하시겠습니까?\n저장되지 않은 입력사항은 사라집니다.") == false) {
					return false;
				}
				var param = {
					machine_plant_seq : row.machine_plant_seq
				}
				$M.goNextPage(this_page, $M.toGetParam(param));
			}, 100);
		}

		// 저장
		function goModify() {
            var isGridChanged = false;
            var isReservePage = "${show_reserve_yn}" == 'Y' ? true : false;
            var isReserved = ${reserved_seq} != 0 ? true : false;

            var msg = $('#reserve_yn').prop('checked') && !isReservePage && isReserved
                ? "변경예약 건이 존재합니다.\n정말 덮어씌우시겠습니까?" : "저장하시겠습니까?";

            if (isReserved && !isReservePage) {
                alert("예약건이 존재합니다.\n예약원가 페이지에서 수정해주세요.")
                return false;
            }

            // 예약일시 현재보다 이전 시간으로 설정 불가
            if ($M.getValue("change_reserve_hour") != "") {
                const currentTime = new Date();
                const reserveDt = $M.getValue("change_reserve_dt");
                const reserveDateTime = new Date(reserveDt.slice(0, 4), reserveDt.slice(4, 6) - 1, reserveDt.slice(6, 8), $M.getValue("change_reserve_hour"));
                const reserveTime = reserveDateTime.getTime();
                if (reserveTime < currentTime) {
                    alert("변경예약일시는 현재보다 이전이 될 수 없습니다.")
                    return false;
                }
            }

            var frm = $M.toValueForm(document.main_form);
            var gridIds = [auiGridFOB, auiGridCIF, auiGridMV, auiGridBA, auiGridNEW, auiGridMA];

            var concatCols = [];
            var concatList = [];
            for (var i=0; i<gridIds.length; i++) {
                var data = AUIGrid.exportToObject(gridIds[i]);
                for (var j=0; j<data.length; j++) {
                    if (data[j].item_name.trim() == "") {
                        alert("항목명 혹은 금액에는 빈칸이 올 수 없습니다.");
                        return false;
                    }
                }
                concatList = concatList.concat(data);
                concatCols = concatCols.concat(fnGetColumns(gridIds[i]));

                // 변경내역 확인
                var addGridData = AUIGrid.getAddedRowItems(gridIds[i]);     // 추가내역
                var editedGridData = AUIGrid.getEditedRowItems(gridIds[i]); // 변경내역
                var removeGridData = AUIGrid.getRemovedItems(gridIds[i]);   // 삭제내역
                if (editedGridData.length != 0 || addGridData.length != 0 || removeGridData.length != 0) {
                    isGridChanged = true;
                }
            }
            $M.setHiddenValue(frm, "grid_changed_yn", isGridChanged);

            var gridFrm = fnGridDataToForm(concatCols, concatList);
            $M.copyForm(gridFrm, frm);

            if (isReservePage) {
                goReserve(gridFrm);
            } else {
			    $M.goNextPageAjaxMsg(msg, this_page+"/modify", gridFrm, {method : 'POST'},
					function(result) {
				    	if(result.success) {
                            // 변경예약 시 reload
                            if ($('#reserve_yn').prop('checked')) {
                                self.location.reload();
                                return;
                            }
				    		// 목록 다시 조회
				    		try {
				    			if (opener != null && opener.goSearch) {
				    				opener.goSearch();
				    			}
				    			var param = {
					    			mch_cost_price_seq : result.mch_cost_price_seq,
                                    machine_plant_seq : result.machine_plant_seq
					    		}
					    		$M.goNextPage("/sale/sale0207p01", $M.toGetParam(param));
				    		} catch (e) {
				    			console.log(e);
				    		}
						}
					}
                );
            }
		}

		// 닫기
		function fnClose() {
			window.close();
		}
		// 소계
		function show1() {
			document.getElementById("show1").style.display="block";
		}

		function hide1() {
			document.getElementById("show1").style.display="none";
		}
		// FOB
		function show2() {
			document.getElementById("show2").style.display="block";
		}
		function hide2() {
			document.getElementById("show2").style.display="none";
		}
		// KRW
		function show3() {
			document.getElementById("show3").style.display="block";
		}
		function hide3() {
			document.getElementById("show3").style.display="none";
		}
		// 통관/내륙운반소계
		function show4() {
			document.getElementById("show4").style.display="block";
		}
		function hide4() {
			document.getElementById("show4").style.display="none";
		}
		// 기본지급품소계
		function show5() {
			document.getElementById("show5").style.display="block";
		}
		function hide5() {
			document.getElementById("show5").style.display="none";
		}
		// 서비스비용
		function show6() {
			document.getElementById("show6").style.display="block";
		}
		function hide6() {
			document.getElementById("show6").style.display="none";
		}
		// 마진소계
		function show7() {
			document.getElementById("show7").style.display="block";
		}
		function hide7() {
			document.getElementById("show7").style.display="none";
		}
		// 신장비도입 소계
		function show8() {
			document.getElementById("show8").style.display="block";
		}
		function hide8() {
			document.getElementById("show8").style.display="none";
		}
		// 일반관리비
		function show9() {
			document.getElementById("show9").style.display="block";
		}
		function hide9() {
			document.getElementById("show9").style.display="none";
		}
		// 대리점공급가
		function show10() {
			document.getElementById("show10").style.display="block";
		}
		function hide10() {
			document.getElementById("show10").style.display="none";
		}
		// 리스트가
		function show11() {
			document.getElementById("show11").style.display="block";
		}
		function hide11() {
			document.getElementById("show11").style.display="none";
		}
		// 프로모션판매가
		function show12() {
			document.getElementById("show12").style.display="block";
		}
		function hide12() {
			document.getElementById("show12").style.display="none";
		}
		// 프로모션가(본사)
		function show13() {
			document.getElementById("show13").style.display="block";
		}
		function hide13() {
			document.getElementById("show13").style.display="none";
		}
		// 프로모션가(대리점)
		function show14() {
			document.getElementById("show14").style.display="block";
		}
		function hide14() {
			document.getElementById("show14").style.display="none";
		}

        function goChangeHistory() {
            let params = {
                "machine_plant_seq" : $M.getValue("machine_plant_seq"),
            }
            $M.goNextPage('/sale/sale0207p0101', $M.toGetParam(params), {popupStatus: ""});
        }

        //그리드 행추가
        function fnAdd(auiGridId) {
            var item = new Object();
            item.cmd = "C";

            var mchType;
            switch (auiGridId) {
                case '#auiGridFOB':
                    mchType = 'FOB';
                    break;
                case '#auiGridCIF':
                    mchType = 'CIF';
                    break;
                case '#auiGridMV':
                    mchType = 'MV';
                    break;
                case '#auiGridBA':
                    mchType = 'BA';
                    break;
                case '#auiGridNEW':
                    mchType = 'NEW';
                    break;
                case '#auiGridMA':
                    mchType = 'MA';
                    break;
            }
            item.mch_type_cd = mchType;
            AUIGrid.addRow(auiGridId, item, "last");
            // 7번 그리드 첫번째 항목명 "대리점수수료"로 고정 및 '수정가능' 컬럼 N 설정
            if (auiGridId === "#auiGridMA") {
                // [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
                // AUIGrid.setCellValue(auiGridMA, 0, "item_name", "대리점수수료");
                AUIGrid.setCellValue(auiGridMA, 0, "item_name", "위탁판매점수수료");
                AUIGrid.setCellValue(auiGridMA, 0, "modify_yn", "N");
            }

            // 해당 모델과 MCH 타입에서 가장 큰 seq_no 값의 +1값을 넣어준다
            fnGetMaxSeqNo(auiGridId, AUIGrid.getRowCount(auiGridId), mchType);
        }

        // ① FOB 그리드
        function createAUIGridFOB() {
            var columnLayout = [
                {
                    headerText : "항목명",
                    dataField : "item_name",
                    width : "50%",
                    style : "aui-left aui-editable",
                },
                {
                    headerText : "금액",
                    dataField : "item_price",
                    dataType : "numeric",
                    formatString: "#,##0",
                    width : "35%",
                    style : "aui-right aui-editable",
                    editRenderer : {
                        type : "InputEditRenderer",
                        onlyNumeric : true,
                        allowNegative : true,
                        // 에디팅 유효성 검사
                        validator : AUIGrid.commonValidator
                    }
                },
                {
                    headerText : "삭제",
                    width : "15%",
                    style : "aui-center",
                    dataField : "removeBtn",
                    editable : false,
                    renderer : {
                        type : "ButtonRenderer",
                        onClick : function(event) {
                            fnRemoveRow(event);
                        }
                    },
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return '삭제'
                    },
                },
                {
                    dataField : "seq_no",
                    visible : false
                },
                {
                    dataField : "mch_type_cd",
                    visible : false
                },
                {
                    dataField : "cmd",
                    visible : false
                },
                {
                    dataField : "group_no",
                    visible : false
                },
                {
                    dataField : "modify_yn",
                    visible : false
                },
                {
                    dataField : "mch_cost_price_dtl_seq",
                    visible : false
                }
            ];

            var footerLayout = [];
            footerLayout[0] = [
                {
                    labelText : "소계",
                    positionField : "item_name",
                    style : "aui-right aui-footer",
                    colspan: 3,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item, dataField, cItem) {
                        return '<span>소계 </span><i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show1()" onmouseout="javascript:hide1()"></i>';
                    }
                },
                {
                    dataField : "item_price",
                    positionField : "item_price",
                    dataType : "numeric",
                    operation : "SUM",
                    formatString: "#,##0",
                    style : "aui-right aui-footer",
                },
            ];

            var gridPros = Object.assign({}, commonGridProsWithFooter);
            gridPros.footerRowCount = 1;
            auiGridFOB = AUIGrid.create("#auiGridFOB", columnLayout, gridPros);
            AUIGrid.setGridData(auiGridFOB, ${list_FOB});
            AUIGrid.setSorting(auiGridFOB, [{dataField : "seq_no", sortType : 1}]);
            AUIGrid.setFooter(auiGridFOB, footerLayout);
            AUIGrid.bind(auiGridFOB, "cellEditEnd", function(event) {
                // FOB합계 setValue
                $M.setValue("fob_total_amt", parseInt(AUIGrid.getFooterData(auiGridFOB)[0][1].value));
                // 수정 후 CMD 설정
                if (!AUIGrid.isAddedById(event.pid, event.item._$uid)) {
                    AUIGrid.setCellValue(auiGridFOB, event.rowIndex, "cmd", "U");
                }
                fnApplyErPrice();
            });
            AUIGrid.bind(auiGridFOB, "removeRow", function(event) {
                $M.setValue("fob_total_amt", parseInt(AUIGrid.getFooterData(auiGridFOB)[0][1].value));
                fnApplyErPrice();
            });
            AUIGrid.resize(auiGridFOB);
        }

        // ② CIF 그리드
        function createAUIGridCIF() {
            var columnLayout = [
                {
                    headerText : "항목명",
                    dataField : "item_name",
                    width : "50%",
                    style : "aui-left aui-editable",
                },
                {
                    headerText : "금액",
                    dataField : "item_price",
                    width : "35%",
                    dataType : "numeric",
                    formatString: "#,##0",
                    style : "aui-right aui-editable",
                    editRenderer : {
                        type : "InputEditRenderer",
                        onlyNumeric : true,
                        allowNegative : true,
                        // 에디팅 유효성 검사
                        validator : AUIGrid.commonValidator
                    }
                },
                {
                    headerText : "삭제",
                    width : "15%",
                    style : "aui-center",
                    dataField : "removeBtn",
                    editable : false,
                    renderer : {
                        type : "ButtonRenderer",
                        onClick : function(event) {
                            fnRemoveRow(event);
                        }
                    },
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return '삭제'
                    },
                },
                {
                    dataField : "seq_no",
                    visible : false
                },
                {
                    dataField : "mch_type_cd",
                    visible : false
                },
                {
                    dataField : "cmd",
                    visible : false
                },
                {
                    dataField : "group_no",
                    visible : false
                },
                {
                    dataField : "modify_yn",
                    visible : false
                },
                {
                    dataField : "mch_cost_price_dtl_seq",
                    visible : false
                }
            ];

            auiGridCIF = AUIGrid.create("#auiGridCIF", columnLayout, commonGridPros);
            AUIGrid.setGridData(auiGridCIF, ${list_CIF});
            AUIGrid.setSorting(auiGridCIF, [{dataField : "seq_no", sortType : 1}]);
            AUIGrid.bind(auiGridCIF, "cellEditEnd", function(event) {
                // 금액의 합계를 구해서 setValue
                cifSubTotal = calcSum(event.pid);
                // 수정 후 CMD 설정
                if (!AUIGrid.isAddedById(event.pid, event.item._$uid)) {
                    AUIGrid.setCellValue(auiGridCIF, event.rowIndex, "cmd", "U");
                }
                fnApplyErPrice();
            });
            AUIGrid.resize(auiGridCIF);
        }

        // ③ 통관 그리드
        function createAUIGridMV() {
            var columnLayout = [
                {
                    headerText : "항목명",
                    dataField : "item_name",
                    width : "50%",
                    style : "aui-left aui-editable",
                },
                {
                    headerText : "금액",
                    dataField : "item_price",
                    width : "35%",
                    dataType : "numeric",
                    formatString: "#,##0",
                    style : "aui-right aui-editable",
                    editRenderer : {
                        type : "InputEditRenderer",
                        onlyNumeric : true,
                        allowNegative : true,
                        // 에디팅 유효성 검사
                        validator : AUIGrid.commonValidator
                    }
                },
                {
                    headerText : "삭제",
                    width : "15%",
                    style : "aui-center",
                    dataField : "removeBtn",
                    editable : false,
                    renderer : {
                        type : "ButtonRenderer",
                        onClick : function(event) {
                            fnRemoveRow(event);
                        }
                    },
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return '삭제'
                    },
                },
                {
                    dataField : "seq_no",
                    visible : false
                },
                {
                    dataField : "mch_type_cd",
                    visible : false
                },
                {
                    dataField : "cmd",
                    visible : false
                },
                {
                    dataField : "group_no",
                    visible : false
                },
                {
                    dataField : "modify_yn",
                    visible : false
                },
                {
                    dataField : "mch_cost_price_dtl_seq",
                    visible : false
                }
            ];

            auiGridMV = AUIGrid.create("#auiGridMV", columnLayout, commonGridPros);
            AUIGrid.setGridData(auiGridMV, ${list_MV});
            AUIGrid.setSorting(auiGridMV, [{dataField : "seq_no", sortType : 1}]);
            AUIGrid.bind(auiGridMV, "cellEditEnd", function(event) {
                // 총 금액의 합계를 구하여 값 저장
                mvSubTotal = calcSum(auiGridMV);
                // 수정 후 CMD 설정
                if (!AUIGrid.isAddedById(event.pid, event.item._$uid)) {
                    AUIGrid.setCellValue(auiGridMV, event.rowIndex, "cmd", "U");
                }
                fnApplyErPrice();
            });
            AUIGrid.bind(auiGridMV, "removeRow", function(event) {
                mvSubTotal = calcSum(auiGridMV);
                fnApplyErPrice();
            });
            AUIGrid.resize(auiGridMV);
        }

        // ④ 기본지급품 그리드
        function createAUIGridBA() {
            var columnLayout = [
                {
                    headerText : "항목명",
                    dataField : "item_name",
                    width : "50%",
                    style : "aui-left aui-editable",
                },
                {
                    headerText : "금액",
                    dataField : "item_price",
                    width : "35%",
                    dataType : "numeric",
                    formatString: "#,##0",
                    style : "aui-right aui-editable",
                    editRenderer : {
                        type : "InputEditRenderer",
                        onlyNumeric : true,
                        allowNegative : true,
                        // 에디팅 유효성 검사
                        validator : AUIGrid.commonValidator
                    }
                },
                {
                    headerText : "삭제",
                    width : "15%",
                    style : "aui-center",
                    dataField : "removeBtn",
                    editable : false,
                    renderer : {
                        type : "ButtonRenderer",
                        onClick : function(event) {
                            fnRemoveRow(event);
                        }
                    },
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return '삭제'
                    },
                },
                {
                    dataField : "seq_no",
                    visible : false
                },
                {
                    dataField : "mch_type_cd",
                    visible : false
                },
                {
                    dataField : "cmd",
                    visible : false,
                },
                {
                    dataField : "group_no",
                    visible : false
                },
                {
                    dataField : "modify_yn",
                    visible : false
                },
                {
                    dataField : "mch_cost_price_dtl_seq",
                    visible : false
                }
            ];

            var footerLayout = [];
            footerLayout[0] = [
                {
                    labelText : "소계",
                    positionField : "item_name",
                    style : "aui-right aui-footer",
                    colspan: 3,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item, dataField, cItem) {
                        return '<span>소계 </span><i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show5()" onmouseout="javascript:hide5()"></i>';
                    },
                },
                {
                    dataField : "item_price",
                    positionField : "item_price",
                    operation : "SUM",
                    formatString: "#,##0",
                    style : "aui-right aui-footer",
                },
            ];
            footerLayout[1] = [
                {
                    labelText : "①+②+③+④ 합계(KRW)",
                    positionField : "item_name",
                    style : "aui-right aui-footer",
                    colspan: 3,
                },
                {
                    dataField : "item_price",
                    positionField : "item_price",
                    operation : "SUM",
                    formatString: "#,##0",
                    style : "aui-right aui-footer",
                    expFunction: function (columnValues) {
                        if (columnValues.length !== 0) {
                            return $M.toNum($M.getValue("group_1_total_amt")) + columnValues.reduce(function add(sum, currValue) {
                                $M.setValue("group_2_total_amt", sum + currValue);
                                return sum + currValue;
                            }, 0);
                        }
                        return $M.toNum($M.getValue("group_1_total_amt"));
                    }
                },
            ];

            auiGridBA = AUIGrid.create("#auiGridBA", columnLayout, commonGridProsWithFooter);
            AUIGrid.setGridData(auiGridBA, ${list_BA});
            AUIGrid.setSorting(auiGridBA, [{dataField : "seq_no", sortType : 1}]);
            AUIGrid.setFooter(auiGridBA, footerLayout);
            AUIGrid.bind(auiGridBA, "cellEditEnd", function(event) {
                $M.setValue("ba_total_amt", calcSum(auiGridBA));
                // 수정 후 CMD 설정
                if (!AUIGrid.isAddedById(event.pid, event.item._$uid)) {
                    AUIGrid.setCellValue(auiGridBA, event.rowIndex, "cmd", "U");
                }
                fnApplyErPrice();
            });
            AUIGrid.bind(auiGridBA, "removeRow", function(event) {
                $M.setValue("ba_total_amt", calcSum(auiGridBA));
                fnApplyErPrice();
            });
            AUIGrid.resize(auiGridBA);
        }

        // ⑥ 신장비도입비용 그리드
        function createAUIGridNEW() {
            var columnLayout = [
                {
                    headerText : "항목명",
                    dataField : "item_name",
                    width : "50%",
                    style : "aui-left aui-editable",
                },
                {
                    headerText : "금액",
                    dataField : "item_price",
                    width : "35%",
                    dataType : "numeric",
                    formatString: "#,##0",
                    style : "aui-right aui-editable",
                    editRenderer : {
                        type : "InputEditRenderer",
                        onlyNumeric : true,
                        allowNegative : true,
                        // 에디팅 유효성 검사
                        validator : AUIGrid.commonValidator
                    }
                },
                {
                    headerText : "삭제",
                    width : "15%",
                    style : "aui-center",
                    dataField : "removeBtn",
                    editable : false,
                    renderer : {
                        type : "ButtonRenderer",
                        onClick : function(event) {
                            fnRemoveRow(event);
                        }
                    },
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return '삭제'
                    },
                },
                {
                    dataField : "seq_no",
                    visible : false
                },
                {
                    dataField : "mch_type_cd",
                    visible : false
                },
                {
                    dataField : "cmd",
                    visible : false
                },
                {
                    dataField : "group_no",
                    visible : false
                },
                {
                    dataField : "modify_yn",
                    visible : false
                },
                {
                    dataField : "mch_cost_price_dtl_seq",
                    visible : false
                }
            ];

            var footerLayout = [];
            footerLayout[0] = [
                {
                    positionField : "item_name",
                    style : "aui-right aui-footer",
                    colspan: 3,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item, dataField, cItem) {
                        return '<span>소계 </span><i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show8()" onmouseout="javascript:hide8()"></i>';
                    },
                },
                {
                    positionField : "item_price",
                    dataField : "item_price",
                    operation : "SUM",
                    formatString: "#,##0",
                    style : "aui-right aui-footer",
                },
            ];

            var gridPros = Object.assign({}, commonGridProsWithFooter);
            gridPros.footerRowCount = 1;
            auiGridNEW = AUIGrid.create("#auiGridNEW", columnLayout, gridPros);
            AUIGrid.setGridData(auiGridNEW, ${list_NEW});
            AUIGrid.setSorting(auiGridNEW, [{dataField : "seq_no", sortType : 1}]);
            AUIGrid.setFooter(auiGridNEW, footerLayout);
            AUIGrid.bind(auiGridNEW, "cellEditEnd", function(event) {
                $M.setValue("new_total_amt", parseInt(AUIGrid.getFooterData(auiGridNEW)[0][1].value));
                // 수정 후 CMD 설정
                if (!AUIGrid.isAddedById(event.pid, event.item._$uid)) {
                    AUIGrid.setCellValue(auiGridNEW, event.rowIndex, "cmd", "U");
                }
                fnApplyErPrice();
            });
            AUIGrid.bind(auiGridNEW, "removeRow", function(event) {
                $M.setValue("new_total_amt", calcSum(auiGridNEW));
                fnApplyErPrice();
            });
            AUIGrid.resize(auiGridNEW);
        }

        // ⑦ 대리점마진 그리드
        function createAUIGridMA() {
            var columnLayout = [
                {
                    headerText : "항목명",
                    dataField : "item_name",
                    width : "50%",
                    style : "aui-left aui-editable",
                },
                {
                    headerText : "금액",
                    dataField : "item_price",
                    width : "35%",
                    dataType : "numeric",
                    formatString: "#,##0",
                    style : "aui-right aui-editable",
                    editRenderer : {
                        type : "InputEditRenderer",
                        onlyNumeric : true,
                        allowNegative : true,
                        // 에디팅 유효성 검사
                        validator : AUIGrid.commonValidator
                    }
                },
                {
                    headerText : "삭제",
                    width : "15%",
                    style : "aui-center",
                    dataField : "removeBtn",
                    editable : false,
                    renderer : {
                        type : "ButtonRenderer",
                        onClick : function(event) {
                            // 첫번째 행 고정
                            if (event.rowIndex === 0) {
                                return false;
                            }
                            fnRemoveRow(event);
                        }
                    },
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return '삭제'
                    },
                },
                {
                    dataField : "seq_no",
                    visible : false
                },
                {
                    dataField : "mch_type_cd",
                    visible : false
                },
                {
                    dataField : "cmd",
                    visible : false
                },
                {
                    dataField : "group_no",
                    visible : false
                },
                {
                    dataField : "modify_yn",
                    visible : false,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        if (rowIndex === 0) {
                            return "N";
                        }
                    }
                },
                {
                    dataField : "mch_cost_price_dtl_seq",
                    visible : false
                }
            ];

            var footerLayout = [];
            footerLayout[0] = [
                {
                    labelText : "소계",
                    positionField : "item_name",
                    style : "aui-right aui-footer",
                    colspan: 3,
                },
                {
                    positionField : "item_price",
                    dataField : "item_price",
                    operation : "SUM",
                    dataType : "numeric",
                    formatString: "#,##0",
                    style : "aui-right aui-footer",
                },
            ];
            footerLayout[1] = [
                {
                    labelText : "①+②+③+④+⑤+⑥+⑦ 총원가",
                    positionField : "item_name",
                    style : "aui-right aui-footer",
                    colspan: 3,
                },
                {
                    positionField : "item_price",
                    dataField : "item_price",
                    operation : "SUM",
                    dataType : "numeric",
                    formatString: "#,##0",
                    style : "aui-right aui-footer",
                    expFunction: function (columnValues) {
                        return $M.toNum($M.getValue("group_4_total_amt")) + calcSum(auiGridMA);
                    }
                },
            ];

            auiGridMA = AUIGrid.create("#auiGridMA", columnLayout, commonGridProsWithFooter);
            AUIGrid.setGridData(auiGridMA, ${list_MA});
            AUIGrid.setSorting(auiGridMA, [{dataField : "seq_no", sortType : 1}]);
            AUIGrid.setFooter(auiGridMA, footerLayout);
            AUIGrid.resize(auiGridMA);
            AUIGrid.bind(auiGridMA, "cellEditBegin", function(event) {
                // 첫번째 열의 항목명 수정 및 삭제 불가
                if (event.rowIndex === 0 && event.dataField === 'item_name') {
                    return false;
                }
            });
            AUIGrid.bind(auiGridMA, "cellEditEnd", function(event) {
                var maTotalAmt = parseInt(AUIGrid.getFooterData(auiGridMA)[0][1].value);
                $M.setValue("ma_total_amt", maTotalAmt);
                $M.setValue("group_5_total_amt", $M.toNum($M.getValue("group_4_total_amt")) + maTotalAmt);
                // 수정 후 CMD 설정
                if (!AUIGrid.isAddedById(event.pid, event.item._$uid)) {
                    AUIGrid.setCellValue(auiGridMA, event.rowIndex, "cmd", "U");
                }
                fnApplyErPrice();
            });
            AUIGrid.bind(auiGridMA, "removeRow", function(event) {
                var maTotalAmt = parseInt(AUIGrid.getFooterData(auiGridMA)[0][1].value);
                $M.setValue("ma_total_amt", maTotalAmt);
                $M.setValue("group_5_total_amt", $M.toNum($M.getValue("group_4_total_amt")) + maTotalAmt);
                fnApplyErPrice();
            });
        }

        // 해당 그리드의 총 금액을 리턴
        function calcSum(auiGridId) {
            let sum = 0;
            var data = AUIGrid.getGridData(auiGridId);
            for (let i=0; i<data.length; i++) {
                // NaN일 경우 0
                var price = parseInt(data[i].item_price) || 0;
                sum += price;
            }
            return sum;
        }

        function fnRemoveRow(event) {
            AUIGrid.setCellValue(event.pid, event.rowIndex, "cmd", "D");
            AUIGrid.removeRow(event.pid, event.rowIndex);
        }

        // 예약일자
        function fnValidationCalDate() {
            // 예약일자는 현재보다 이전이 될 수 없다
            if (!$M.checkRangeByValue($M.getCurrentDate(), $M.getValue("change_reserve_dt"))) {
                alert("변경예약일은 현재보다 이전이 될 수 없습니다.")
                fnSetCalDateToday();
                return false;
            }
        }

        // 예약내역이 있다면 안내 후 팝업창 띄우기
        function goReservePopup() {
            if ("${reserved_seq}" != 0 && "${show_reserve_yn}" != 'Y') {
                if (!confirm("변경예약 내역이 존재합니다. 예약건을 조회하시겠습니까?")) {
                    return false;
                }

                var params = {
                    mch_cost_price_seq : "${reserved_seq}",
                    machine_plant_seq : "${item.machine_plant_seq}",
                    price_apply_yn : 'N',
                    show_reserve_yn : 'Y',
                }

                $M.goNextPage('/sale/sale0207p01', $M.toGetParam(params), {popupStatus: 'true', popupTitle: 'true'});
            }
        }

        // 콤보박스 선택 시 호출
        function goReservePage(value) {
            switch(value) {
                case '현재원가':
                    return;
                case '예약원가':
                    break;
            }

            var params = {
                machine_plant_seq : "${item.machine_plant_seq}",
                mch_cost_price_seq : "${reserved_seq}",
                price_apply_yn : 'N',
                show_reserve_yn : 'Y'
            }

            $M.goNextPage('/sale/sale0207p01', $M.toGetParam(params), {popupStatus: 'true', popupTitle: 'true'});

            if ("${show_reserve_yn}" != 'Y') {
                $("#reserve_combo option:eq(0)").attr("selected", "selected");
            }
        }

        // 예약일시 체크박스 설정
        function fnSetReserveDT() {
            if ($('#reserve_yn').prop('checked')) {
                fnSetCalDateToday();
                // 현재시간 + 1시간으로 설정
                let now = new Date();
                let hour = now.getHours() + 1 > 23 ? 0 : now.getHours() + 1;
                document.getElementById("change_reserve_hour").options[hour+1].selected = true;
                $('#reserve_yn').val("Y");
            } else {
                $("#change_reserve_dt").val("");
                document.getElementById("change_reserve_hour").options[0].selected = true;
                $('#reserve_yn').val("N");
            }
        }

        // 예약일을 현재날짜로 설정
        function fnSetCalDateToday() {
            let now = new Date();
            now = now.getFullYear() + "-" + ("0" + (now.getMonth() + 1)).slice(-2) + "-" + ("0" + now.getDate()).slice(-2);
            $("#change_reserve_dt").val(now);
        }

        // 예약원가 페이지에서의 반영
        function goReserve(gridFrm) {
            var reserveYn = $('#reserve_yn').prop('checked');
            var msg = reserveYn ? "반영하시겠습니까?" : "즉시 반영하시겠습니까?";

            $M.goNextPageAjaxMsg(msg, this_page+"/reserve", gridFrm, {method : 'POST'},
                function(result) {
                    if(result.success) {
                        // 예약수정 시
                        if (reserveYn) {
                            self.location.reload();
                        } else {
                            fnReserveResult(result);
                        }
                    }
                }
            );
        }

        function fnReload(param) {
            $M.goNextPage("/sale/sale0207p01", $M.toGetParam(param), {popupStatus : ""});
        }

        function fnReserveResult(result) {
            var param = {
                mch_cost_price_seq : result.mch_cost_price_seq,
                machine_plant_seq : result.machine_plant_seq,
                price_apply_yn : 'Y'
            }
            // 즉시반영 시
            if (opener != null) {
                // 본창 재조회
                if (opener.opener != null) {
                    opener.opener.goSearch();
                }
                // 부모 팝업창
                opener.fnReload(param);
                self.close();
            } else {
                $M.goNextPage("/sale/sale0207p01", $M.toGetParam(param), {popupStatus : ""});
            }
        }

        function fnGetMaxSeqNo(auiGridId, rowIdx, mchType) {
            var param = {
                machine_plant_seq : $M.getValue("machine_plant_seq"),
                mch_type_cd : mchType
            }
            $M.goNextPageAjax(this_page + '/getSeqNo', $M.toGetParam(param), {method : 'GET', loader : false, async : false},
                function(result) {
                    if (result.success) {
                        var maxSeqNo = $M.toNum(result.max_seq_no);
                        // 해당 그리드에 해당 seq_no 가 존재한다면 +1값을 넣어준다
                        var seqList = AUIGrid.getColumnValues(auiGridId, "seq_no");
                        while (seqList.includes(maxSeqNo)) {
                            maxSeqNo += 1;
                        }
                        AUIGrid.setCellValue(auiGridId, rowIdx, "seq_no", maxSeqNo);
                    }
                });
        }

        function goCancelResv() {
            if (!confirm("예약을 취소하시겠습니까?")) {
                return;
            }

            var param = {
                mch_cost_price_seq : $M.getValue("mch_cost_price_seq")
            }

            $M.goNextPageAjax(this_page + '/cancel_reserve', $M.toGetParam(param), {method : "GET"},
                function(result) {
                    if (result.success) {
                        alert("예약이 취소되었습니다.");
                        if (opener != null) {
                            opener.location.reload();
                        }
                        window.close();
                    }
                });
        }
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <input type="hidden" id="mch_cost_price_seq" name="mch_cost_price_seq" value="${item.mch_cost_price_seq}">
    <input type="hidden" id="machine_plant_seq" name="machine_plant_seq" value="${item.machine_plant_seq}">
    <input type="hidden" id="money_unit_cd" name="money_unit_cd" value="${item.money_unit_cd}">
    <input type="hidden" id="fob_total_amt" name="fob_total_amt" value="${item.fob_total_amt}">
    <input type="hidden" id="ba_total_amt" name="ba_total_amt" value="${item.ba_total_amt}">
    <input type="hidden" id="ma_total_amt" name="ma_total_amt" value="${item.ma_total_amt}">
    <input type="hidden" id="new_total_amt" name="new_total_amt" value="${item.new_total_amt}">
    <input type="hidden" id="group_2_total_amt" name="group_2_total_amt" value="${item.group_2_total_amt}">
    <input type="hidden" id="show_reserve_yn" name="show_reserve_yn" value="${show_reserve_yn}">
    <input type="hidden" id="price_apply_yn" name="price_apply_yn" value="${item.price_apply_yn}">
    <input type="hidden" id="reserved_seq" name="reserved_seq" value="${reserved_seq}">
<div class="layout-box">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="">
<!-- 상세페이지 타이틀 -->
				<div class="">
<!-- 검색영역 -->
                    <div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="140px">
								<col width="90px">
								<col width="90px">
								<col width="60px">
                                <col width="800px">
                                <col width="80px">
                                <col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>모델명</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0" value="${machine_name}">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="openSearchModelPanel('goMachineCost', 'N')"><i class="material-iconssearch"></i></button>
										</div>
									</td>
									<th>적용환율(${item.money_unit_cd})</th>
									<td>
										<div class="col width90px">
   											<input type="text" class="form-control text-right" id="apply_er_price" name="apply_er_price" format="decimal" value="${item.apply_er_price}">
										</div>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:fnApplyErPrice()">적용</button>
									</td>
                                    <td>
										<span class="text-warning" style="float: right;">${item.price_apply_yn eq 'N' and show_reserve_yn ne 'Y' and show_reserve_yn eq '' ? "목록에서 환율일괄적용된 원가입니다. 저장하려면 반영버튼을 눌러주세요." : ""}</span>
                                    </td>
                                    <td>
                                        <div>
                                            <select class="form-control" id="reserve_combo" name="reserve_combo" style="width: 70px" onchange="goReservePage(this.value)">
                                                <c:if test="${show_reserve_yn ne 'Y'}">
                                                    <option onclick=""> 현재원가 </option>
                                                </c:if>
                                                <c:if test="${reserved_seq ne 0}">
                                                    <option <c:if test="${show_reserve_yn eq 'Y'}">selected="selected"</c:if> > 예약원가 </option>
                                                </c:if>
                                            </select>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="btn-group">
                                            <div class="left"></div>
                                            <div class="right">
                                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                                            </div>
                                        </div>
                                    </td>
								</tr>
							</tbody>
						</table>
					</div>
<!-- /검색영역 -->




<!-- 폼테이블 -->
					<div class="row">
<!-- 좌측 폼테이블 -->
						<div class="col-4">
<!-- ① FOB(JPY) -->
							<div class="title-wrap mt10">
                                <div class="form-inline">
                                    <h4>①</h4><input type="text" class="form-control text-left" id="title_FOB" name="title_FOB" value="${title.FOB}" style="width: 150px; margin-left: 5px">
                                </div>
                                <div><button type="button" class="btn btn-default" onclick="javascript:fnAdd(auiGridFOB)">행추가</button></div>
							</div>
                            <!-- ① FOB 그리드 -->
                            <div id="auiGridFOB" style="margin-top: 5px;"></div>
                            <!-- FOB 소계 도움말 -->
                            <div class="con-info" id="show1" style="max-height: 500px; left: 48%; width: 245px; display: none; top:15%;">
                                <ul><li>소계 = ① FOB 그리드 총금액</li></ul>
<%--                                <ul><li>소계=FOB(KRW)+가격조정항목1~4</li></ul>--%>
                            </div>

                            <div class="title-wrap mt10">
                                <h4>발주옵션</h4>
                            </div>
                            <div class="mt5" style="height: 60px;">
                                <textarea class="form-control" style="height: 100%;" id="order_text" name="order_text">${item.order_text}</textarea>
                            </div>

							<%--
							<table class="table-border mt5">
                                <colgroup>
                                    <col width="180px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th class="text-right">FOB(${item.money_unit_cd})</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="fob_price" name="fob_price" format="num" value="${item.fob_price}" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">가격조정항목 1</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="fob_adjust_1_price" name="fob_adjust_1_price" format="num" value="${item.fob_adjust_1_price}" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">가격조정항목 2</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="fob_adjust_2_price" name="fob_adjust_2_price" format="num" value="${item.fob_adjust_2_price}" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">가격조정항목 3</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="fob_adjust_3_price" name="fob_adjust_3_price" format="num" value="${item.fob_adjust_3_price}" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">가격조정항목 4</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="fob_adjust_4_price" name="fob_adjust_4_price" format="num" value="${item.fob_adjust_4_price}" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right th-orange">소계<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show1()" onmouseout="javascript:hide1()"></i></th>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci" readonly="readonly" tabindex="-1" id="fob_sub_amt" name="fob_sub_amt" format="num" value="${item.fob_sub_amt}" title="소계=FOB(KRW)+가격조정항목1~4">
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">가격조정항목 5</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="fob_adjust_5_price" name="fob_adjust_5_price" format="num" value="${item.fob_adjust_5_price}" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">가격조정항목 6</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="fob_adjust_6_price" name="fob_adjust_6_price" format="num" value="${item.fob_adjust_6_price}" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right th-orange">FOB합계<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show2()" onmouseout="javascript:hide2()"></i></th>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci" readonly="readonly" tabindex="-1" id="fob_total_amt" name="fob_total_amt" format="num" value="${item.fob_total_amt}" title="FOB합계=소계+가격조정항목5~6">
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                            --%>
<!-- /① FOB(JPY) -->
<!-- ② CIF Price(JPY) -->
                            <div class="title-wrap mt10">
                                <div class="form-inline">
                                    <h4>②</h4><input type="text" class="form-control text-left" id="title_CIF" name="title_CIF" value="${title.CIF}" style="width: 150px; margin-left: 5px">
                                </div>
                                <div>
                                    <button type="button" class="btn btn-default" onclick="javascript:fnAdd(auiGridCIF)">행추가</button>
                                </div>
                            </div>
                            <!-- ② CIF 그리드 -->
                            <div id="auiGridCIF" style="margin-top: 5px;"></div>
                            <!-- ② Interest Cost 테이블 -->
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="200px">
                                    <col width="70px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="text-right" colspan="2">Interest cost(%)<input type="text" class="text-right" id="cif_interest_rate" name="cif_interest_rate" format="decimal" value="${item.cif_interest_rate }" style="margin-left: 5px; margin-right: 5px; width: 50px;">%</th>
                                    <td class="text-right">
                                        <input type="text" class="form-control text-right ci" readonly="readonly" tabindex="-1" id="cif_interest_amt" name="cif_interest_amt" format="num" value="${item.cif_interest_amt}" title="FOB합계 * Interest cost(%)">
                                    </td>
                                </tr>
                                </tbody>
                            </table>
                            <!-- ② 소계, KRW 테이블 -->
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="200px">
                                    <col width="70px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="text-right" colspan="2">소계</th>
                                    <td class="text-right">
                                        <input type="text" class="form-control text-right ci" readonly="readonly" tabindex="-1" id="cif_total_amt" name="cif_total_amt" format="num" value="${item.cif_total_amt}" title="소계 = FOB합계 + Interest AMT + ② 그리드 총금액">
                                    </td>
                                </tr>
                                <tr>
                                    <th class="text-right th-orange" colspan="2">KRW(CIF소계 환율적용)<i class="material-iconserror font-16" style="vertical-align: middle; margin-left: 3px;" onmouseover="javascript:show3()" onmouseout="javascript:hide3()"></i></th>
                                    <div class="con-info" id="show3" style="max-height: 500px; left: 52%; width: 245px; display: none; top:42%;">
                                        <ul class="">
                                            <li>Interest cost = FOB소계 * %</li>
                                            <li>CIF KRW = 소계 * 적용환율</li>
                                        </ul>
                                    </div>
                                    <td class="text-right">
                                        <input type="text" class="form-control text-right ci bd" readonly="readonly" tabindex="-1" id="cif_krw_amt" name="cif_krw_amt" format="num" value="${item.cif_krw_amt}" title="CIF KRW = 소계*적용환율">
                                    </td>
                                </tr>
                                </tbody>
                            </table>
<%--
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="110px">
                                    <col width="70px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th class="text-right" colspan="2">CIF Charge</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="cif_charge" name="cif_charge" format="num" value="${item.cif_charge }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" colspan="2">추가항목 1</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="cif_add_1_price" name="cif_add_1_price" format="num" value="${item.cif_add_1_price }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" colspan="2">${item.money_unit_cd}소계</th>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci" readonly="readonly" tabindex="-1" id="cif_total_amt" name="cif_total_amt" format="num" value="${item.cif_total_amt}" title="소계=FOB합계+Interest AMT+CIF Charge, 추가항목1은 계산에 참여하지않음.">
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right th-orange" colspan="2">KRW(CIF소계 환율적용)<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show3()" onmouseout="javascript:hide3()"></i></th>
                                        <div class="con-info" id="show3" style="max-height: 500px; left: 48%; width: 245px; display: none; top:39%;">
											<ul class="">
												<li>Interest cost = FOB소계 * %</li>
												<li>CIF KRW = 소계*적용환율</li>
											</ul>
										</div>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci bd" readonly="readonly" tabindex="-1" id="cif_krw_amt" name="cif_krw_amt" format="num" value="${item.cif_krw_amt}" title="CIF KRW = 소계*적용환율">
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
--%>
<!-- /② CIF Price(JPY) -->
<!-- ③ 통관/내륙운반(KRW) -->
                            <div class="title-wrap mt10">
                                <div class="form-inline">
                                    <h4>③</h4><input type="text" class="form-control text-left" id="title_MV" name="title_MV" value="${title.MV}" style="width: 150px; margin-left: 5px">
                                </div>
                                <div><button type="button" class="btn btn-default" onclick="javascript:fnAdd(auiGridMV)">행추가</button></div>
                            </div>
                            <!-- ③ 통관 그리드 -->
                            <div id="auiGridMV" style="margin-top: 5px;"></div>
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="200px">
                                    <col width="70px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th class="text-right" colspan="2">
                                            통관비<input type="text" class="text-right" id="mv_pass_rate" name="mv_pass_rate" format="decimal" value="${item.mv_pass_rate }" style="margin-left: 5px; margin-right: 5px; width: 50px">%
                                        </th>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci" readonly="readonly" tabindex="-1" id="mv_pass_amt" name="mv_pass_amt" format="num" value="${item.mv_pass_amt}" title="통관비 = CIF KRW * 통관비%">
                                        </td>
                                    </tr>
<%--
                                    <tr>
                                        <th class="text-right" colspan="2">내륙운반비(Container)</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="mv_move_price" name="mv_move_price" format="num" value="${item.mv_move_price }">
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" colspan="2">추가항목 1</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="mv_add_1_price" name="mv_add_1_price" format="num" value="${item.mv_add_1_price }" >
                                        </td>
                                    </tr>
--%>
                                </tbody>
                            </table>
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="200px">
                                    <col width="70px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th class="text-right th-orange" colspan="2">소계<i class="material-iconserror font-16" style="vertical-align: middle; margin-left: 3px" onmouseover="javascript:show4()" onmouseout="javascript:hide4()"></i></th>
                                        <div class="con-info" id="show4" style="max-height: 500px; left: 48%; width: 300px; display: none; top:66%;">
                                            <ul class="">
                                                <li>통관비 = CIF KRW * 통관비%</li>
                                                <li>통관/내륙운반소계 = 통관비 + ③ 통관 그리드 총금액</li>
                                            </ul>
                                        </div>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci bd" readonly="readonly" tabindex="-1" id="mv_total_amt" name="mv_total_amt" format="num" value="${item.mv_total_amt}" title="통관/내륙운반소계 = 통관비+내륙운반+추가항목1">
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right th-sum" colspan="2">①+②+③ 합계(KRW)</th>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci bd" readonly="readonly" tabindex="-1" id="group_1_total_amt" name="group_1_total_amt" format="num" value="${item.group_1_total_amt}" title="1+2+3 합계 = CIF KRW + 통관/내륙운반소계">
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
<!-- /③ 통관/내륙운반(KRW) -->
<!-- ④ 기본지급품 -->
                            <div class="title-wrap mt10">
                                <div class="form-inline">
                                    <h4>④</h4><input type="text" class="form-control text-left" id="title_BA" name="title_BA" value="${title.BA}" style="width: 150px; margin-left: 5px">
                                </div>
                                <div><button type="button" class="btn btn-default" onclick="javascript:fnAdd(auiGridBA)">행추가</button></div>
                            </div>
                            <!-- ④ 기본지급품 그리드 -->
                            <div id="auiGridBA" style="margin-top: 5px;"></div>
                            <!-- 기본지급품 소계 도움말 -->
                            <div class="con-info" id="show5" style="max-height: 500px; left: 48%; width: 245px; display: none; top:92%;">
                                <ul><li>소계 = ④ 기본지급품 그리드 총금액</li></ul>
                            </div>
<%--
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="110px">
                                    <col width="70px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th class="text-right" colspan="2">대버켓</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ba_big_bucket_price" name="ba_big_bucket_price" format="num" value="${item.ba_big_bucket_price }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" colspan="2">중버켓</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ba_mid_bucket_price" name="ba_mid_bucket_price" format="num" value="${item.ba_mid_bucket_price }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" colspan="2">소버켓</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ba_small_bucket_price" name="ba_small_bucket_price" format="num" value="${item.ba_small_bucket_price }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" colspan="2">자동링크</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ba_auto_link_price" name="ba_auto_link_price" format="num" value="${item.ba_auto_link_price }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" colspan="2">기본지급품</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ba_base_item_price" name="ba_base_item_price" format="num" value="${item.ba_base_item_price }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" colspan="2">필터세트</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ba_filter_price" name="ba_filter_price" format="num" value="${item.ba_filter_price }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" colspan="2">라디오</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ba_radio_price" name="ba_radio_price" format="num" value="${item.ba_radio_price }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" colspan="2">캐노피 절단비용</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ba_canopy_cut_price" name="ba_canopy_cut_price" format="num" value="${item.ba_canopy_cut_price }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" colspan="2">운반비(사업장-고객)</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ba_move_price" name="ba_move_price" format="num" value="${item.ba_move_price }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" colspan="2">서비스 DI</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ba_svc_di_price" name="ba_svc_di_price" format="num" value="${item.ba_svc_di_price }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" colspan="2">추가항목 1</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ba_add_1_price" name="ba_add_1_price" format="num" value="${item.ba_add_1_price }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" colspan="2">추가항목 2</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ba_add_2_price" name="ba_add_2_price" format="num" value="${item.ba_add_2_price }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right th-orange" colspan="2">기본 지급품 소계<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show5()" onmouseout="javascript:hide5()"></i></th>
                                        <div class="con-info" id="show5" style="max-height: 500px; left: 48%; width: 245px; display: none; top:94%;">
											<ul class="">
												<li>지급품소계 = 기본지급품 합계</li>
											</ul>
										</div>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci bg" readonly="readonly" tabindex="-1" id="ba_total_amt" name="ba_total_amt" format="num" value="${item.ba_total_amt }">
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="110px">
                                    <col width="70px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th class="text-right th-sum" colspan="2">①+②+③+④ 합계(KRW)</th>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci bg" readonly="readonly" tabindex="-1" id="group_2_total_amt" name="group_2_total_amt" format="num" value="${item.group_2_total_amt }" title="1+2+3+4합계 = 1+2+3합계 + 기본지급품소계">
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
--%>
<!-- /④ 기본지급품 -->
						</div>
<!-- /좌측 폼테이블 -->

<!-- 중앙 폼테이블 -->
                        <div class="col-4">

<!-- ⑤ 일반관리비 -->
                            <div class="title-wrap mt10">
                                <div class="form-inline">
                                    <h4>⑤</h4><input type="text" class="form-control text-left" id="title_MNG" name="title_MNG" value="${title.MNG}" style="width: 150px; margin-left: 5px">
                                </div>
                            </div>
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="200px">
                                    <col width="70px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th class="text-right" colspan="2">
                                            서비스금액<i class="material-iconserror font-16" style="vertical-align: middle; margin-left: 3px;" onmouseover="javascript:show6()" onmouseout="javascript:hide6()"></i>
                                            <input type="text" class="text-right" id="mng_svc_rate" name="mng_svc_rate" format="decimal" value="${item.mng_svc_rate }" style="margin-left: 5px; margin-right: 5px; width: 50px;">
                                            %
                                        </th>
                                            <div class="con-info" id="show6" style="max-height: 500px; left: 48%; width: 245px; display: none; top:3%;">
                                                <ul class="">
                                                    <li>서비스금액 = 최저판매가 * 서비스금액%</li>
                                                    <li>(단, 프로모션가(본사)에 금액이 기재되어 있으면 최저판매가가 아닌 프로모션가 기준으로 계산)</li>
                                                </ul>
                                            </div>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci" readonly="readonly" tabindex="-1" id="mng_svc_amt" name="mng_svc_amt" format="num" value="${item.mng_svc_amt }" title="서비스결정금액=최저판매가 * 서비스결정% (단, 프로모션가(본사)에 금액이 기재되어 있으면 최저판매가가 아닌 프로모션가 기준으로 계산)">
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" colspan="2">
                                            일반관리비<i class="material-iconserror font-16" style="vertical-align: middle; margin-left: 3px;" onmouseover="javascript:show9()" onmouseout="javascript:hide9()"></i>
                                            <input type="text" class="text-right" id="mng_mng_rate" name="mng_mng_rate" format="decimal" value="${item.mng_mng_rate }" style="margin-left: 5px; margin-right: 5px; width: 50px;">
                                            %
                                        </th>
                                        <div class="con-info" id="show9" style="max-height: 500px; left: 48%; width: 245px; display: none; top:3%;">
											<ul class="">
												<li>일반관리비 = 최저판매가 * 일반관리비%</li>
												<li>(단, 프로모션가(본사)에 금액이 기재되어 있으면 최저판매가가 아닌 프로모션가 기준으로 계산)</li>
											</ul>
										</div>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci" readonly="readonly" tabindex="-1" id="mng_mng_amt" name="mng_mng_amt" format="num" value="${item.mng_mng_amt }" title="일반관리비 = 최저판매가 * 일반관리비% (단, 프로모션가(본사)에 금액이 기재되어 있으면 최저판매가가 아닌 프로모션가 기준으로 계산)">
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="200px">
                                    <col width="70px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th class="text-right th-sum" colspan="2">소계</th>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci bg" readonly="readonly" tabindex="-1" id="mng_total_amt" name="mng_total_amt" format="num" value="${item.mng_total_amt}" title="소계 = 서비스금액 + 일반관리비">
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right th-sum" colspan="2">①+②+③+④+⑤ 합계(KRW)</th>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci bg" readonly="readonly" tabindex="-1" id="group_3_total_amt" name="group_3_total_amt" format="num" value="${item.group_3_total_amt }" title="1+2+3+4+5 합계 = 1+2+3+4 합계 + 일반관리비">
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
<!-- /⑤ 일반관리비 -->
<!-- ⑥ 신장비도입비용 -->
                            <div class="title-wrap mt10">
                                <div class="form-inline">
                                    <h4>⑥</h4><input type="text" class="form-control text-left" id="title_NEW" name="title_NEW" value="${title.NEW}" style="width: 150px; margin-left: 5px">
                                </div>
                                <div><button type="button" class="btn btn-default" onclick="javascript:fnAdd(auiGridNEW)">행추가</button></div>
                            </div>
                            <!-- ⑥ 신장비도입비용 그리드 -->
                            <div id="auiGridNEW" style="margin-top: 5px;"></div>
                            <!-- /⑥ 신장비도입비용 그리드 -->
                            <!-- 신장비도입비용 분배 및 ①+②+③+④+⑤+⑥ 합계 -->
                            <table class="table-border mt10">
                                <colgroup>
                                    <col width="220px">
                                    <col width="50px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="text-right th-orange">신장비 도입비용(비용/N)</th>
                                    <td>
                                        <div class="form-row inline-pd widthfix">
                                            <div class="col width50px">
                                                <input type="text" class="form-control text-right" id="new_div_cnt" name="new_div_cnt" format="num" value="${item.new_div_cnt}">
                                            </div>
                                        </div>
                                    </td>
                                    <td class="text-right">
                                        <input type="text" class="form-control text-right ci" readonly="readonly" tabindex="-1" id="new_div_one_amt" name="new_div_one_amt" format="num" value="${item.new_div_one_amt}" title="신장비 도입비용(비용/N) = 신장비도입비용합계/N">
                                    </td>
                                </tr>
                                <tr>
                                    <th class="text-right th-sum" colspan="2">①+②+③+④+⑤+⑥ 합계(KRW)</th>
                                    <td class="text-right">
                                        <input type="text" class="form-control text-right ci bg" readonly="readonly" tabindex="-1" id="group_4_total_amt" name="group_4_total_amt" format="num" value="${item.group_4_total_amt}" title="1+2+3+4+5+6 합계 = 1+2+3+4+5 합계 + 신장비도입비용합계/N">
                                    </td>
                                </tr>
                                </tbody>
                            </table>
                            <!-- /신장비도입비용 분배 및 ①+②+③+④+⑤+⑥ 합계 -->
                            <!-- 신장비도입비용 소계 도움말 -->
                            <div class="con-info" id="show8" style="max-height: 500px; width: 245px; display: none; top:30%; left: 56%;">
                                <ul class="">
                                    <li>소계 = ⑥ 신장비도입비용 그리드 총금액</li>
                                </ul>
                            </div>
                            <!-- /신장비도입비용 소계 도움말 -->
<%--
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="110px">
                                    <col width="70px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="text-right th-sum" colspan="2">①+②+③+④+⑤+⑥ 합계(KRW)</th>
                                    <td class="text-right">
                                        <input type="text" class="form-control text-right ci bg" readonly="readonly" tabindex="-1" id="group_4_total_amt" name="group_4_total_amt" format="num" value="${item.group_4_total_amt}" title="1+2+3+4+5+6 합계 = 1+2+3+4+5+마진소계">
                                    </td>
                                </tr>
                                </tbody>
                            </table>
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="70px">
                                    <col width="110px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th rowspan="5" class="th-skyblue text-center">서비스</th>
                                    <th class="text-right">장비판매관리</th>
                                    <td>
                                        <input type="text" class="form-control text-right" id="new_svc_sale_mng_price" name="new_svc_sale_mng_price" format="num" value="${item.new_svc_sale_mng_price}" >
                                    </td>
                                </tr>
                                <tr>
                                    <th class="text-right">번역(OPM,SM)</th>
                                    <td>
                                        <input type="text" class="form-control text-right" id="new_svc_opm_price" name="new_svc_opm_price" format="num" value="${item.new_svc_opm_price}" >
                                    </td>
                                </tr>
                                <tr>
                                    <th class="text-right">서비스교육</th>
                                    <td>
                                        <input type="text" class="form-control text-right" id="new_svc_edu_price" name="new_svc_edu_price" format="num" value="${item.new_svc_edu_price}" >
                                    </td>
                                </tr>
                                <tr>
                                    <th class="text-right">추가항목 1</th>
                                    <td>
                                        <input type="text" class="form-control text-right" id="new_svc_add_1_price" name="new_svc_add_1_price" format="num" value="${item.new_svc_add_1_price}" >
                                    </td>
                                </tr>
                                <tr>
                                    <th class="text-right">추가항목 2</th>
                                    <td>
                                        <input type="text" class="form-control text-right" id="new_svc_add_2_price" name="new_svc_add_2_price" format="num" value="${item.new_svc_add_2_price}" >
                                    </td>
                                </tr>
                                <tr>
                                    <th rowspan="6" class="th-skyblue text-center">영업</th>
                                    <th class="text-right">형식승인</th>
                                    <td>
                                        <input type="text" class="form-control text-right" id="new_sale_approval_price" name="new_sale_approval_price" format="num" value="${item.new_sale_approval_price}" >
                                    </td>
                                </tr>
                                <tr>
                                    <th class="text-right">소음도검사</th>
                                    <td>
                                        <input type="text" class="form-control text-right" id="new_sale_noise_price" name="new_sale_noise_price" format="num" value="${item.new_sale_noise_price}" >
                                    </td>
                                </tr>
                                <tr>
                                    <th class="text-right">영업교육</th>
                                    <td>
                                        <input type="text" class="form-control text-right" id="new_sale_edu_price" name="new_sale_edu_price" format="num" value="${item.new_sale_edu_price}" >
                                    </td>
                                </tr>
                                <tr>
                                    <th class="text-right">카다로그/홍보물</th>
                                    <td>
                                        <input type="text" class="form-control text-right" id="new_sale_catal_price" name="new_sale_catal_price" format="num" value="${item.new_sale_catal_price}" >
                                    </td>
                                </tr>
                                <tr>
                                    <th class="text-right">추가항목 1</th>
                                    <td>
                                        <input type="text" class="form-control text-right" id="new_sale_add_1_price" name="new_sale_add_1_price" format="num" value="${item.new_sale_add_1_price}" >
                                    </td>
                                </tr>
                                <tr>
                                    <th class="text-right">추가항목 2</th>
                                    <td>
                                        <input type="text" class="form-control text-right" id="new_sale_add_2_price" name="new_sale_add_2_price" format="num" value="${item.new_sale_add_2_price}" >
                                    </td>
                                </tr>
                                </tbody>
                            </table>
--%>
<!-- /⑥ 신장비도입비용 -->
<!-- ⑦ 대리점마진 -->
                            <div class="title-wrap mt10">
                                <div class="form-inline">
                                    <h4>⑦</h4><input type="text" class="form-control text-left" id="title_MA" name="title_MA" value="${title.MA}" style="width: 150px; margin-left: 5px">
                                </div>
                                <div><button type="button" class="btn btn-default" onclick="javascript:fnAdd(auiGridMA)">행추가</button></div>
                            </div>
                            <!-- ⑦ 대리점마진 그리드 -->
                            <div id="auiGridMA" style="margin-top: 5px;"></div>
<%--
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="70px">
                                    <col width="110px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th rowspan="4" class="th-skyblue text-center">대리점</th>
                                        <th class="text-right">대리점 수수료</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ma_agency_margin_amt" name="ma_agency_margin_amt" format="num" value="${item.ma_agency_margin_amt}" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">대리점 인센티브</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ma_agency_incen_amt" name="ma_agency_incen_amt" format="num" value="${item.ma_agency_incen_amt}" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">추가항목 1</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ma_agency_add_1_price" name="ma_agency_add_1_price" format="num" value="${item.ma_agency_add_1_price}" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">추가항목 2</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ma_agency_add_2_price" name="ma_agency_add_2_price" format="num" value="${item.ma_agency_add_2_price}" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right th-orange" colspan="2">마진소계<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show7()" onmouseout="javascript:hide7()"></i></th>
                                        <div class="con-info" id="show7" style="max-height: 500px; left: 48%; width: 400px; display: none; top:20%;">
												<ul class="">
													<li>마진소계 = 대리점수수료+대리점인센티브+추가항목1+추가항목2</li>
													<li>YK 마진 = 1+2+3+4+5+6+7 총원가 - 최저판매가 - 프로모션조정</li>
													<li>YK 마진% = 마진/최저판매가 * 100</li>
												</ul>
											</div>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci bg" readonly="readonly" tabindex="-1" id="ma_total_amt" name="ma_total_amt" format="num" value="${item.ma_total_amt}" title="마진소계 = 대리점수수료+대리점인센티브+추가항목1+추가항목2">
                                        </td>
                                    </tr>
                                    <tr>
                                        <th rowspan="3" class="th-skyblue text-center">YK</th>
                                        <th class="text-right">마진</th>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci" readonly="readonly" tabindex="-1" id="ma_yk_margin_amt" name="ma_yk_margin_amt" format="num" value="${item.ma_yk_margin_amt}" title="YK마진 = 1+2+3+4+5+6+7 총원가 - 최저판매가  - 프로모션조정">
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">마진(%)</th>
                                        <td class="text-right">
                                        	<div class="form-row inline-pd widthfix" style="float: right; padding-right: 5px;">
                                                <div class="col width50px" style="padding: 0;">
                                                    <input type="text" class="form-control text-right ci" readonly="readonly" tabindex="-1" id="ma_yk_margin_rate" name="ma_yk_margin_rate" format="decimal" value="${item.ma_yk_margin_rate}" style="padding: 0;" title="YK마진% = (마진 / 최저판매가) * 100">
                                                </div>
                                                <div class="col width16px">
                                                    %
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">추가항목 1</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="ma_yk_add_1_price" name="ma_yk_add_1_price" format="num" value="${item.ma_yk_add_1_price}">
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
--%>
<!-- /⑦ 대리점마진 -->

                            <table class="table-border mt20 lg-table">
                                <colgroup>
                                    <col width="220px">
                                    <col width="50px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="text-right th-sum" colspan="2">①+②+③+④+⑤+⑥+⑦ 총원가</th>
                                    <td class="text-right">
                                        <input type="text" class="form-control text-right ci bg" readonly="readonly" tabindex="-1" id="group_5_total_amt" name="group_5_total_amt" format="num" value="${item.group_5_total_amt}" title="1+2+3+4+5+6+7 총원가 = 1+2+3+4+5+6 + 신장비도입비용(비용/N)">
                                    </td>
                                </tr>
                                <tr>
<%--                                    <th class="text-right th-sum" colspan="2">YK마진(최저판매가-총원가)</th>--%>
                                    <th class="text-right th-sum" colspan="2">YK마진[최저판매가 or 프로모션가(본사)-총원가]</th>
                                    <td class="text-right">
                                        <input type="text" class="form-control text-right ci" readonly="readonly" tabindex="-1" id="ma_yk_margin_amt" name="ma_yk_margin_amt" format="num" value="${item.ma_yk_margin_amt}" title="YK마진 = 1+2+3+4+5+6+7 총원가 - 최저판매가  - 프로모션조정">
                                    </td>
                                </tr>
                                <tr>
                                    <th class="text-right th-sum" colspan="2">YK마진율</th>
                                    <td class="text-right">
                                        <input type="text" class="text-right ci" readonly="readonly" tabindex="-1" id="ma_yk_margin_rate" name="ma_yk_margin_rate" format="decimal" value="${item.ma_yk_margin_rate}" style="padding: 0;" title="YK마진% = (마진 / 최저판매가) * 100"><span>%</span>
                                    </td>
                                </tr>
                                <tr>
                                    <th class="text-right th" colspan="2">최저판매가</th>
                                    <td class="text-right td">
                                        <input type="text" class="form-control text-right" id="min_sale_price" name="min_sale_price" format="num" value="${item.min_sale_price}" >
                                    </td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
<!-- /중앙 폼테이블 -->
<!-- 우측 폼테이블 -->
						<div class="col-4">
<!-- ⑧ 대리점공급가 -->
                            <div class="title-wrap mt10">
                                <%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
                                <%--<h4>대리점공급가</h4>--%>
                                <h4>위탁판매점공급가</h4>
                            </div>
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="180px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
                                        <%--<th class="text-right">대리점공급가조정</th>--%>
                                        <th class="text-right">위탁판매점공급가조정</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="agency_adjust_amt" name="agency_adjust_amt" format="num" value="${item.agency_adjust_amt }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">
                                        	<!-- DB에 대리점최저판매가=대리점최저공급가 (21.8.4)-->
                                            <%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
                                            <%--<strong>대리점최저공급가격<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show10()" onmouseout="javascript:hide10()"></i></strong>--%>
                                            <strong>위탁판매점최저공급가격<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show10()" onmouseout="javascript:hide10()"></i></strong>
                                        </th>
                                        <div class="con-info" id="show10" style="max-height: 500px; left: 35%; width: 300px; display: none; top:8%;">
												<ul class="">
                                                    <%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
													<%--<li>대리점최저공급가격 = 최저판매가 - 대리점공급가조정</li>--%>
													<li>위탁판매점최저공급가격 = 최저판매가 - 위탁판매점공급가조정</li>
												</ul>
											</div>
                                        <td class="text-right">
                                            <%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
                                            <%--<input type="text" class="form-control text-right ci bg" readonly="readonly" tabindex="-1" id="agency_min_sale_price" name="agency_min_sale_price" format="num" value="${item.agency_min_sale_price}" title="대리점최저공급가격 = 최저판매가 - 대리점공급가조정">--%>
                                            <input type="text" class="form-control text-right ci bg" readonly="readonly" tabindex="-1" id="agency_min_sale_price" name="agency_min_sale_price" format="num" value="${item.agency_min_sale_price}" title="위탁판매점최저공급가격 = 최저판매가 - 위탁판매점공급가조정">
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
<!-- /⑧ 대리점공급가 -->
<!-- ⑨ 리스트가 -->
                            <div class="title-wrap mt15">
                                <h4>리스트가</h4>
                            </div>
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="180px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th class="text-right">리스트가조정</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="list_adjust_amt" name="list_adjust_amt" format="num" value="${item.list_adjust_amt }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">
                                            <strong>판매가격(리스트)<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show11()" onmouseout="javascript:hide11()"></i></strong>
                                        </th>
                                        <div class="con-info" id="show11" style="max-height: 500px; left: 40%; width: 280px; display: none; top:14%;">
												<ul class="">
													<li>판매가격(리스트) = 최저판매가 + 리스트가조정</li>
												</ul>
											</div>
                                        <td class="text-right">
                                            <input type="text" class="form-control text-right ci bg" readonly="readonly" tabindex="-1" id="list_sale_price" name="list_sale_price" format="num" value="${item.list_sale_price }" title="판매가격(리스트) = 최저판매가 + 리스트가조정">
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
<!-- /⑨ 리스트가 -->
<!-- ⑩ 프로모션판매가 -->
                            <div class="title-wrap mt10">
                                <h4>프로모션판매가</h4>
                            </div>
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="180px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th class="text-right">프로모션가 조정</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="pro_adjust_amt" name="pro_adjust_amt" format="num" value="${item.pro_adjust_amt }" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" style="background: orange;">
                                            <strong>프로모션가(본사)<i class="material-iconserror font-16" style="vertical-align: middle; margin-left: 3px;" onmouseover="javascript:show13()" onmouseout="javascript:hide13()"></i></strong>
                                        </th>
                                        <div class="con-info" id="show13" style="max-height: 500px; left: 42%; width: 270px; display: none; top:23%;">
												<ul class="">
													<li>프로모션가(본사) = 최저판매가 - 프로모션가조정</li>
												</ul>
											</div>
                                        <td class="text-right" style="background: antiquewhite;">
                                            <input type="text" class="form-control text-right ci bg" readonly="readonly" tabindex="-1" id="base_pro_sale_price" name="base_pro_sale_price" format="num" value="${item.base_pro_sale_price }" title="프로모션가(본사) = 최저판매가 - 프로모션가조정">
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right" style="background: orange;">
                                            <%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
                                           <%--<strong>프로모션공급가(대리점)<i class="material-iconserror font-16" style="vertical-align: middle; margin-left: 3px;" onmouseover="javascript:show14()" onmouseout="javascript:hide14()"></i></strong>--%>
                                           <strong>프로모션공급가(위탁판매점)<i class="material-iconserror font-16" style="vertical-align: middle; margin-left: 3px;" onmouseover="javascript:show14()" onmouseout="javascript:hide14()"></i></strong>
                                        </th>
                                        <div class="con-info" id="show14" style="max-height: 500px; left: 42%; width: 270px; display: none; top:23%;">
												<ul class="">
                                                    <%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
													<%--<li>프로모션가(대리점) = 대리점최저공급가격 - 프로모션가조정</li>--%>
													<li>프로모션가(위탁판매점) = 위탁판매점최저공급가격 - 프로모션가조정</li>
												</ul>
											</div>
                                        <td class="text-right" style="background: antiquewhite;">
                                            <%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
                                            <%--<input type="text" class="form-control text-right ci bg" readonly="readonly" tabindex="-1" id="agency_pro_sale_price" name="agency_pro_sale_price" format="num" value="${item.agency_pro_sale_price }" title="프로모션가(대리점) = 대리점최저공급가격 - 프로모션가조정">--%>
                                            <input type="text" class="form-control text-right ci bg" readonly="readonly" tabindex="-1" id="agency_pro_sale_price" name="agency_pro_sale_price" format="num" value="${item.agency_pro_sale_price }" title="프로모션가(위탁판매점) = 위탁판매점최저공급가격 - 프로모션가조정">
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
<!-- /⑩ 프로모션판매가 -->
<!-- ⑪ 할인한도 -->
                            <div class="title-wrap mt15">
                                <h4>할인한도(최저판매가-작성전결가)</h4>
                            </div>
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="180px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th class="text-right">할인한도</th>
                                        <td>
                                            <input type="text" class="form-control text-right ci" id="max_dc_price" name="max_dc_price" format="num" value="${item.max_dc_price }" title="할인한도 = 최저판매가 - 작성전결가" readonly="readonly">
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
<!-- /⑪ 할인한도 -->
<!-- ⑫ 전결기준가 -->
                            <div class="title-wrap mt15">
                                <h4>전결기준가</h4>
                            </div>
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="180px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th class="text-right">작성전결</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="write_price" name="write_price" format="num" value="${item.write_price }">
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">심사전결</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="review_price" name="review_price" format="num" value="${item.review_price }">
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">합의전결</th>
                                        <td>
                                            <input type="text" class="form-control text-right" id="agree_price" name="agree_price" format="num" value="${item.agree_price }">
                                        </td>
                                    </tr>
                                </tbody>
                            </table>

                            <%-- <div class="title-wrap mt15">
                                <h4>품의가격</h4>
                            </div>
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="180px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th class="text-right">기준판매가</th>
                                        <td>
                                            <input type="text" class="form-control text-right ci" readonly="readonly" tabindex="-1" format="num" value="<fmt:formatNumber type="number" maxFractionDigits="3" value="${item.sale_price }" />" title="기준판매가 = 프로모션가(본사), 없으면 최저판매가">
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">대리점가</th>
                                        <td>
                                            <input type="text" class="form-control text-right ci" readonly="readonly" tabindex="-1" format="num" value="<fmt:formatNumber type="number" maxFractionDigits="3" value="${item.agency_pro_sale_price }" />" title="대리점가 = 프로모션공급가(대리점), 없으면 대리점최저공급가격">
                                        </td>
                                    </tr>
                                </tbody>
                            </table> --%>
<!-- /⑫ 전결기준가 -->
<!-- 변경사유 -->
                            <div class="title-wrap mt10">
                                <h4>변경사유</h4>
                            </div>
                            <div class="mt5" style="height: 160px;">
								<textarea class="form-control" style="height: 100%;" id="change_remark" name="change_remark">${item.change_remark }</textarea>
							</div>
<!-- /판매가 변경사유 -->
<!-- 변경예약 -->
                            <div class="title-wrap mt10">
                                <h4>변경예약<span class="text-warning" style="margin-left: 5px;">※ 월~금(08~19시) 정시에 실행</span></h4>
                            </div>
                            <div>
                                <table class="table-border mt5">
                                    <colgroup>
                                        <col width="100px">
                                        <col width="">
                                    </colgroup>
                                    <tbody>
                                    <tr>
                                        <th class="text-right">
                                            <input class="form-check-input" id="reserve_yn" name="reserve_yn" type="checkbox" value="N" onchange="fnSetReserveDT();" />
                                            <span>예약일시</span>
                                        </th>
                                        <td>
                                            <div class="form-row inline-pd">
                                                <input type="text" class="border-right-0 calDate" id="change_reserve_dt" name="change_reserve_dt" dateformat="yyyy-MM-dd" alt="변경예약일시" size="12" maxlength="8" value="${item.change_reserve_dt}" style="height: 24px; margin-left: 10px;" onChange="fnValidationCalDate();"/>
                                                <div class="pl5" style="margin-left: 5px;">
                                                    <select class="form-control width45px p2b" id="change_reserve_hour" name="change_reserve_hour">
                                                        <option value=""></option>
                                                        <c:forEach var="ti" begin="00" end="23" step="1">
                                                            <option <c:if test="${ti eq item.change_reserve_hour}">selected="selected"</c:if> >
                                                                <c:if test="${ti < 10}">0</c:if><c:out value="${ti}"/>
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="pl5">시</div>
                                            </div>
                                        </td>
                                    </tr>
                                    </tbody>
                                </table>
                            </div>
<!-- /변경예약 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
                            <div class="btn-group mt10">
                                <div class="right">
                                    <c:if test="${show_reserve_yn eq 'Y'}">
                                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_M"/></jsp:include>
                                    </c:if>
                                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                                </div>
                            </div>
<!-- /그리드 서머리, 컨트롤 영역 -->
						</div>
<!-- /우측 폼테이블 -->
					</div>
<!-- /폼테이블 -->
				</div>
			</div>
		</div>

    </div>
<!-- /팝업 -->
</div>
</form>
</body>
</html>
