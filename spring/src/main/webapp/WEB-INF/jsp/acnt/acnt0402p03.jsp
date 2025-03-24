<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 대리점월정산 > null > 월 정산서관리-대리점
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGridLeftTop();
			createAUIGridLeftBottom();
			
			createAUIGridRight();
			fnDealyAmtCalc();   // 장비미수금 지연금 구하기
			fnPartMisuCalc();   // 미수금[부품] - 정산예정 금액 구하기
			
			fnApprControl();  // 결재라인 세팅
			calcAmt();
			fnCalcMchAmt(); // 정산예정 - 장비대
		});

		// 미수금[부품] - 정산예정 금액 구하기
		function fnPartMisuCalc() {
			// 정산예정 계산
			// 지급예정 합계 - 정산명세 지연금 - 기타 > 부품미수금   : 부품미수금
			//                            else 계산된 금액
			var gridData = AUIGrid.getGridData(auiGridRight);  // 미수금현황[부품] 그리드 데이터
			var val = gridData[0].calc_amt;	// 정산예정금
			var payTotalAmt = $M.getValue("pay_total_amt"); 		// 지급예정 합계 
			var resultDelayAmt = $M.getValue("result_delay_amt");   // 정산명세 지연금
			var resultEtcAmt = $M.getValue("result_etc_amt");       // 기타
			var edMisuAmt = gridData[0].ed_misu_amt;  // 부품 미수금
			
			var calcVal = Number(payTotalAmt) - Number(resultDelayAmt) - Number(resultEtcAmt);
			
			if ($M.getValue("agency_pay_status_cd") == "") {
				if (calcVal > edMisuAmt) {
					val = edMisuAmt;
				} else {
					val = calcVal;
				}
			}
			
			AUIGrid.updateRow(auiGridRight, {"calc_amt" : val}, 0, false);	
		}
		
		function fnDealyAmtCalc() {
			var payCommission = $M.getValue("pay_commission");
			var payVat = $M.getValue("pay_vat");
			var Claims = $M.getValue("as_money");

			// 미수금현황[장비] - 정산예정 지연금 계산
			var miAmount = 0;
// 			var delayCalc = $M.getValue("pay_total_amt");  // 지급예정의 합계
			var delayCalc = parseInt(payCommission) + parseInt(payVat) + parseInt(Claims);  // 지급예정의 합계
			var delayCalcAmt = 0;
			var delayGubun = false;  // 구분
			var agencyPayStatusCd = $M.getValue("agency_pay_status_cd");
			
			var gridData = AUIGrid.getGridData(auiGridLeftTop);  // 미수금현황[장비] 그리드 데이터
			
			// 결재상태가 정산처리완료가 아닐경우에만 실행
			if (agencyPayStatusCd == "") {
				for (var i = 0; i < gridData.length; i++) {
					delayCalc = delayCalc - gridData[i].calc_delay_amt;  // 지급예정의 합계 - 정산예정지연금
					if (delayCalc < 0) {
						// 지급예정의 합계 - 정산예정지연금이 0보다 작으면 정산예정 지연금, 장비대, 합계 0으로 세팅.
// 						var rowIdField = AUIGrid.getProp(auiGridLeftTop, "rowIdField");
						var rowIndex = AUIGrid.rowIdToIndex(auiGridLeftTop, gridData[i]._$uid);
						var data = {
								calc_delay_amt : 0,
								calc_mch_amt : 0,
								calc_summony : 0
						}
						AUIGrid.updateRow(auiGridLeftTop, data, rowIndex, false);						
						delayGubun = true;
					} else {
						// 지급예정의 합계 - 정산예정지연금이 0보다 크면 정산예정 지연금 누적
						delayCalcAmt = delayCalcAmt + gridData[i].calc_delay_amt;
					}
				}
			}
			
			var sumDelayAmt = AUIGrid.getFooterData(auiGridLeftTop)[4].text;
			$M.setValue("result_delay_amt", sumDelayAmt);
			
			var sumMchAmt = AUIGrid.getFooterData(auiGridLeftTop)[5].text;
			$M.setValue("result_mch_amt", sumMchAmt);
		}
		
		// 정산예정 장비대
		function fnCalcMchAmt() {
			var payTotalAmt = parseInt($M.getValue("pay_total_amt"));  // 지급예정의 합계
			var resultTotalAmt = parseInt($M.getValue("result_total_amt"));  // 정산명세 합계
			
			console.log("payTotalAmt : ", payTotalAmt);
			console.log("resultTotalAmt : ", resultTotalAmt);
			
			var gridData = AUIGrid.getGridData(auiGridLeftTop);  // 미수금현황[장비] 그리드 데이터
			
			var resultAmt = payTotalAmt - resultTotalAmt;
			console.log("resultAmt : ", resultAmt); // 11,391
			
			var agencyPayStatusCd = $M.getValue("agency_pay_status_cd");
			console.log("agencyPayStatusCd : ", agencyPayStatusCd);
			
			if (agencyPayStatusCd == "") {
				for (var i = 0; i < gridData.length; i++) {
					console.log("gridData[i] : ", gridData[i]);
					var planDt = gridData[i].plan_dt;  // 예정일
					var payDt = gridData[i].pay_dt;  // 정산일
					var miamount = gridData[i].miamount;  // 미결재금
					var delayAmt = gridData[i].delay_amt;  // 지연금
					var miaSumAmt = miamount + delayAmt; // 장비미수 미결재금 + 지연금 
					
					// 예정일이 지났을경우.
					if (planDt < payDt) {
						if (resultAmt > 0) {
							if (resultAmt < miaSumAmt) {
								console.log("gridData[i].calc_delay_amt : ", gridData[i].calc_delay_amt);
								console.log("resultAmt : ", resultAmt);
								
								
								var rowIndex = AUIGrid.rowIdToIndex(auiGridLeftTop, gridData[i]._$uid);
								var data = {
										calc_mch_amt : resultAmt,
										calc_summony : gridData[i].calc_delay_amt + resultAmt
								}
								AUIGrid.updateRow(auiGridLeftTop, data, rowIndex, false);	
								var sumMchAmt = AUIGrid.getFooterData(auiGridLeftTop)[5].text;
								$M.setValue("result_mch_amt", sumMchAmt);
								calcAmt();
								
								resultAmt = 0;
							} else {
								var rowIndex = AUIGrid.rowIdToIndex(auiGridLeftTop, gridData[i]._$uid);
								var data = {
										calc_mch_amt : miaSumAmt,
										calc_summony : gridData[i].calc_delay_amt + miaSumAmt
								}
								AUIGrid.updateRow(auiGridLeftTop, data, rowIndex, false);	
								var sumMchAmt = AUIGrid.getFooterData(auiGridLeftTop)[5].text;
								$M.setValue("result_mch_amt", sumMchAmt);
								calcAmt();
								
								resultAmt = resultAmt - miaSumAmt;
							}
						}
					}
				}
			}
		}
		
		// 결재라인 세팅
		function fnApprControl() {
			var status = $M.getValue("agency_pay_status_cd");
			
			$M.setValue("apprName1", $M.getValue("req_mem_name"));
			$M.setValue("apprNum1", $M.getValue("req_mem_no"));
			$M.setValue("apprName2", $M.getValue("app_mem_name"));
			$M.setValue("apprNum2", $M.getValue("app_mem_no"));
			$M.setValue("apprName3", $M.getValue("chk_mem_name"));
			$M.setValue("apprNum3", $M.getValue("chk_mem_no"));
			$M.setValue("apprName4", $M.getValue("pay_mem_name"));
			$M.setValue("apprNum4", $M.getValue("pay_mem_no"));
			
			var str1 = $("#apprStatus1").text($M.getValue("req_mem_no") == "" ? "" : "승인\n" + $M.getValue("req_date")); 
			str1.html(str1.html().replace(/\n/g, '<br/>'));
			
			var str2 = $("#apprStatus2").text($M.getValue("app_mem_no") == "" ? "" : "승인\n" + $M.getValue("app_date"));
			str2.html(str2.html().replace(/\n/g, '<br/>'));
			
			var str3 = $("#apprStatus3").text($M.getValue("chk_mem_no") == "" ? "" : "승인\n" + $M.getValue("chk_date"));
			str3.html(str3.html().replace(/\n/g, '<br/>'));
			
			var str4 = $("#apprStatus4").text($M.getValue("pay_mem_no") == "" ? "" : "승인\n" + $M.getValue("pay_date"));
			str4.html(str4.html().replace(/\n/g, '<br/>'));
			
			$M.setValue("remark", $M.getValue("pay_remark"));
		}
		
		// 결재
		function goRequestApproval() {
			if ($M.getValue("apprNum1") == "") {
				alert("결재요청자를 선택해 주세요.");
				return;
			}
			
			goSave('requestAppr');
		}
		
		// 저장
		function goSave(isRequestAppr) {
			var msg = "결재하시겠습니까?"

			var frm = document.main_form;
			frm = $M.toValueForm(frm);
			
			var topGridData = AUIGrid.getGridData(auiGridLeftTop);
			var botGridData = AUIGrid.getGridData(auiGridLeftBottom);
			var rightGridData = AUIGrid.getGridData(auiGridRight);
			
			// 결재 요청
			if (isRequestAppr != undefined) {
				$M.setValue("save_mode", "appr");
				$M.setValue("calc_amt", rightGridData[0].calc_amt);
				$M.setValue("ed_misu_amt", rightGridData[0].ed_misu_amt);
				$M.setValue("req_mem_no", $M.getValue("apprNum1"));
				msg = "결재요청 하시겠습니까?";
			}
			
			// TODO : 최초결재
			
			/*  
				1. t_agency_pay (대리점정산) - INSERT
				- pay_dt				정산일자
				- org_code				대리점코드
				- agency_pay_status_cd	대리점정산상태코드 (1:결재중, 2:결재완료, 3:대리점확인, 9:정산완료)
				- remark				비고
				- req_mem_no			요청직원
				- req_date				요청일시
				- result_delay_amt		정산지연금
				- result_etc_amt		정산기타
				- result_part_amt		정산부품
				- result_mch_amt		정산장비대
			*/
			
			/*
				2. t_agency_pay_mch (대리점정산 장비미수) - UPDATE
				set
				- minus_amt				삭감액
				- calc_delay_amt		정산예정 지연금
				- calc_mch_amt			정산예정 장비대
				
				where
				- machine_doc_no	장비품의서번호
				- pat_dt			정산일자
				- org_code			조직코드
			*/
			
			/*
				3. t_agency_pay_commission (대리점정산 수수료) - UPDATE
				set
				- pay_sale_amt			지급 수수료
				- pay_vat_amt			지급 부가세
				
				where
				- machine_doc_no	장비품의서번호
				- pat_dt			정산일자
				- org_code			조직코드
			*/
			
			/*
				4. t_agency_pay_part (대리점정산 부품) - UPDATE
				set
				- calc_amt			정산예정
				
				where
				- pat_dt			정산일자
				- org_code			조직코드
			*/
			
			/*
				5. t_agency_pay_etc
				6. t_agency_pay_as
				두가지는 AS-IS의 PAY쪽에만 저장함.. 
			*/
			
			// t_agency_pay_mch
			var mchMachineDocNoArr = [];
			var machinePayTypeCdArr = [];
			var minusAmtArr = [];
			var calcDelayAmtArr = [];
			var calcMchAmtArr = [];
			
			// t_agency_pay_commission
			var machineDocNoArr = [];
			var paySaleAmtArr = [];
			var payVatAmtArr = [];
			
			for (var i = 0; i < topGridData.length; i++) {
				mchMachineDocNoArr.push(topGridData[i].machine_doc_no);
				machinePayTypeCdArr.push(topGridData[i].machine_pay_type_code);
				minusAmtArr.push(topGridData[i].minus_amt);
				calcDelayAmtArr.push(topGridData[i].calc_delay_amt);
				calcMchAmtArr.push(topGridData[i].calc_mch_amt);
			}
			
			for (var i = 0; i < botGridData.length; i++) {
				machineDocNoArr.push(botGridData[i].machine_doc_no);
				paySaleAmtArr.push(botGridData[i].pay_salemoney);
				payVatAmtArr.push(botGridData[i].pay_vat_amt);
			}
			
			var option = {
					isEmpty : true
			};
			
			$M.setValue(frm, "mch_machine_doc_no_str", $M.getArrStr(mchMachineDocNoArr, option));
			$M.setValue(frm, "machine_pay_type_cd_str", $M.getArrStr(machinePayTypeCdArr, option));
			$M.setValue(frm, "minus_amt_str", $M.getArrStr(minusAmtArr, option));
			$M.setValue(frm, "calc_delay_amt_str", $M.getArrStr(calcDelayAmtArr, option));
			$M.setValue(frm, "calc_mch_amt_str", $M.getArrStr(calcMchAmtArr, option));

			$M.setValue(frm, "machine_doc_no_str", $M.getArrStr(machineDocNoArr, option));
			$M.setValue(frm, "pay_sale_amt_str", $M.getArrStr(paySaleAmtArr, option));
			$M.setValue(frm, "pay_vat_amt_str", $M.getArrStr(payVatAmtArr, option));
			
			console.log("frm : ", frm);
			
			$M.goNextPageAjaxMsg(msg, this_page + "/save", frm , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("처리가 완료되었습니다.");
		    			window.opener.goSearch();
		    			fnClose();
					}
				}
			);			
		}
		
		// 받아온 값 세팅할 name 구하는데 사용
		var nameStr 		= "apprName";
		var memNoStr 		= "apprNum";
		var apprStatusStr 	= "apprStatus";
		// 받아온 값 세팅할 name
		var setName 	= "";	// 회원이름의 name명
		var setMemNo 	= "";	// 회원번호의 name명
		var seqNum		= 0;	// 저장 및 삭제할 input의 번호
		
		// 직원조회 팝업 호출 버튼값을 받아옴(세팅할 inputBox row Num)
		function __fnMemListPopup(num) {
			seqNum = num;
			openSearchMemberPanel("__fnSetApprMember");
		}
		
		// 직원조회 결과 데이터 받아서 세팅 
		function __fnSetApprMember(result) {
			var rsName 	= result.mem_name;
			var rsMemNo = result.mem_no;
			
			// 저장할 name명 세팅
			setName 	= nameStr.concat(seqNum);
			setMemNo 	= memNoStr.concat(seqNum);
			// 결재선 라인에 값 세팅
			var frm 	= document.main_form;
			$M.setValue(frm, setName, rsName);
			$M.setValue(frm, setMemNo, rsMemNo);
		}
		
		// x 버튼 클릭 시 inputbox 초기화
		function __fnMemNameDel(seqNum) {
			var frm = document.main_form;
			var nameDel 	= nameStr.concat(seqNum);
			var memNoDel 	= memNoStr.concat(seqNum);
			var statusDel 	= apprStatusStr.concat(seqNum);
			$M.setValue(frm, nameDel, "");
			$M.setValue(frm, memNoDel, "");
			$("#"+statusDel).text("");
		}
		
		//그리드생성
		function createAUIGridLeftTop() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				editable : true,
				showFooter : true,
				footerPosition : "top",
				enableMovingColumn : false,
// 				// fixedColumnCount : 6,
			};
			var columnLayout = [
				{
					dataField : "machine_doc_no",
					visible : false
				},
				{
					headerText : "차주명", 
					dataField : "cust_name", 
					width : "120",
					minWidth : "30",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "125",
					minWidth : "30",
					style : "aui-left aui-popup",
					editable : false,
				},
				{ 
					headerText : "출하일", 
					dataField : "out_dt", 
					width : "65",
					minWidth : "30",
					dataType : "date",  
					formatString : "yy-mm-dd",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "구분", 
					dataField : "cash_case_name",
					width : "60",
					minWidth : "30",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "예정일", 
					dataField : "plan_dt", 
					width : "65",
					minWidth : "30",
					dataType : "date",  
					formatString : "yy-mm-dd",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "미결재금", 
					dataField : "miamount", 
					width : "100",
					minWidth : "30",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false,
				},
				{ 
					headerText : "지연금", 
					dataField : "delay_amt", 
					width : "80",
					minWidth : "30",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false,
				},
				{ 
					headerText : "차감액", 
					dataField : "minus_amt", 
					width : "80",
					minWidth : "30",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : true,
					styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if ($M.getValue("agency_pay_status_cd") != "") {
							return null;
						} else {
							return "aui-editable";
						}
					},
				},
				{
					headerText : "정산예정",
					children : [
						{
							dataField : "calc_delay_amt",
							headerText : "지연금",
							width : "80",
							minWidth : "30",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
							editable : false,
// 							expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
// 								// 합계 계산
// 								var val = (item.delay_amt - item.minus_amt);
// 								return val; 
// 							}
						}, 
						{
							dataField : "calc_mch_amt",
							headerText : "장비대",
							width : "100",
							minWidth : "30",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
							editable : true,
							styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if ($M.getValue("agency_pay_status_cd") != "") {
									return null;
								} else {
									return "aui-editable";
								}
							},
						},
						{
							dataField : "calc_summony",
							headerText : "합계",
							width : "100",
							minWidth : "30",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
							editable : false,
// 							expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
// 								// 합계 계산
// 								var val = (item.calc_delay_amt + item.calc_mch_amt); 
// 								return val;
// 							}
						}
					]
				}, 
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "plan_dt",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "miamount",
					positionField : "miamount",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "delay_amt",
					positionField : "delay_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "minus_amt",
					positionField : "minus_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "calc_delay_amt",
					positionField : "calc_delay_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "calc_mch_amt",
					positionField : "calc_mch_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "calc_summony",
					positionField : "calc_summony",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			
			auiGridLeftTop = AUIGrid.create("#auiGridLeftTop", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGridLeftTop, footerColumnLayout);
			AUIGrid.setGridData(auiGridLeftTop, ${payMachineList});
			$("#auiGridLeftTop").resize();
			// 발주내역 클릭시 -> 발주서상세 팝업 호출
			AUIGrid.bind(auiGridLeftTop, "cellClick", function(event) {
				if(event.dataField == "machine_name" ) {
					var params = {
						"machine_doc_no" : event.item.machine_doc_no
					};
					var popupOption = "";
					$M.goNextPage('/sale/sale0101p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
			
			AUIGrid.bind(auiGridLeftTop, "cellEditEnd", function(event) {
// 				if(event.dataField == "calc_mch_amt" ) {
// 					var minusAmt = event.item.minus_amt;  // 미수금현황[장비] - 차감액
// 					var delayAmt = event.item.delay_amt;  // 미수금현황[장비] - 지연금
// 					var calcMchAmt = event.item.calc_mch_amt; // 미수금현황[장비] - 정산예정 장비대
// 					var calcDealyAmt = delayAmt - minusAmt;  // 미수금현황[장비] - 정산예정 지연금 : 지연금 - 차감액
					
// 					var payTotalAmt = $M.getValue("pay_total_amt"); // 지급예정 합계
// 					var resultDelayAmt = $M.getValue("result_delay_amt"); // 지급예정 지연금
// 					var resultPartAmt = $M.getValue("result_part_amt"); // 지급예정 부품대
					
// 					var resultAmt = payTotalAmt - resultDelayAmt - resultPartAmt;
					
// 					console.log("resultAmt : ", resultAmt);
// 					console.log("calcMchAmt : ", calcMchAmt);
					
// 					if (resultAmt < calcMchAmt) {
// 						console.log("이벤트 : ", event);
// 						alert("장비대는 (지급합계 - 지연금 - 부품대) 보다 클 수 없습니다.");
// 						AUIGrid.showToastMessage(auiGridLeftTop, event.rowIndex, 10, "장비대는 (지급합계 - 지연금 - 부품대) 보다 클 수 없습니다.");
// 						return event.oldValue;
// 						AUIGrid.showToastMessage(auiGridLeftTop, event.rowIndex, 10, "장비대는 (지급합계 - 지연금 - 부품대) 보다 클 수 없습니다.");
// 						return AUIGrid.showToastMessage(auiGridLeftTop, event.rowIndex, 10, "장비대는 (지급합계 - 지연금 - 부품대) 보다 클 수 없습니다.");
						
// 						var data = {
// 								calc_mch_amt : 0,
// 						}
// 						AUIGrid.updateRow(auiGridLeftTop, data, event.rowIndex);
// 					} else {
// 						var data = {
// 								calc_summony : calcDealyAmt + calcMchAmt,
// 						}
// 						AUIGrid.updateRow(auiGridLeftTop, data, event.rowIndex);
// 					}
					
					
// 					// 정산명세 - 장비
// 					$M.setValue("result_mch_amt", AUIGrid.getFooterData(auiGridLeftTop)[5].value);
// 					calcAmt();
// 				}

				if(event.dataField == "minus_amt" ) {
					// 정산명세 - 지연금
					var minusAmt = event.item.minus_amt;  // 미수금현황[장비] - 차감액
					var delayAmt = event.item.delay_amt;  // 미수금현황[장비] - 지연금
					var calcMchAmt = event.item.calc_mch_amt; // 미수금현황[장비] - 정산예정 장비대
					
					var calcDealyAmt = delayAmt - minusAmt;  // 미수금현황[장비] - 정산예정 지연금 : 지연금 - 차감액
					
					if (delayAmt < minusAmt) {
						alert("차감액이 지연금보다 클 수 없습니다.");
						var data = {
								minus_amt : event.oldValue,
								calc_delay_amt : delayAmt - event.oldValue,
								calc_summony : delayAmt - event.oldValue + calcMchAmt,
						}
						AUIGrid.updateRow(auiGridLeftTop, data, event.rowIndex);
						$M.setValue("result_delay_amt", AUIGrid.getFooterData(auiGridLeftTop)[4].value);
						calcAmt();
						return event.oldValue;
					} else {
						var data = {
								calc_delay_amt : calcDealyAmt,
								calc_summony : calcDealyAmt + calcMchAmt,
						}
						AUIGrid.updateRow(auiGridLeftTop, data, event.rowIndex);
						
						$M.setValue("result_delay_amt", AUIGrid.getFooterData(auiGridLeftTop)[4].value);
						calcAmt();
					}
					
				}
			});	

			AUIGrid.bind(auiGridLeftTop, "cellEditBegin", function(event) {
				if ($M.getValue("agency_pay_status_cd") != "") {
					if(event.dataField == "minus_amt" || event.dataField == "calc_mch_amt") {
						return false;
					}
				}
				
			});	

			AUIGrid.bind(auiGridLeftTop, "cellEditEndBefore", function(event) {
				if(event.dataField == "calc_mch_amt" ) {
					var minusAmt = event.item.minus_amt;  // 미수금현황[장비] - 차감액
					var delayAmt = event.item.delay_amt;  // 미수금현황[장비] - 지연금
					var calcMchAmt = event.item.calc_mch_amt; // 미수금현황[장비] - 정산예정 장비대
					var calcDealyAmt = delayAmt - minusAmt;  // 미수금현황[장비] - 정산예정 지연금 : 지연금 - 차감액
					
					var payTotalAmt = $M.getValue("pay_total_amt"); // 지급예정 합계
					var resultDelayAmt = $M.getValue("result_delay_amt"); // 지급예정 지연금
					var resultPartAmt = $M.getValue("result_part_amt"); // 지급예정 부품대
					
					var resultAmt = payTotalAmt - resultDelayAmt - resultPartAmt;
					var totalPayAmt = parseInt($M.getValue("total_pay_amt"));
					
					if (event.oldValue < event.value) {
						if (totalPayAmt < event.value - event.oldValue) {
							alert("장비대는 실 지급예정 보다 클 수 없습니다.");
							
							var data = {
									calc_mch_amt : event.oldValue,
									calc_summony : event.item.calc_delay_amt + event.oldValue,
							}
							AUIGrid.updateRow(auiGridLeftTop, data, event.rowIndex);
							return event.oldValue;
						} else {
							var data = {
									calc_mch_amt : event.value,
									calc_summony : event.item.calc_delay_amt + event.value,
							}
							AUIGrid.updateRow(auiGridLeftTop, data, event.rowIndex);
							var sumMchAmt = AUIGrid.getFooterData(auiGridLeftTop)[5].text;
							$M.setValue("result_mch_amt", sumMchAmt);
							calcAmt();
						}
					} else {
						var data = {
								calc_mch_amt : event.value,
								calc_summony : event.item.calc_delay_amt + event.value,
						}
						AUIGrid.updateRow(auiGridLeftTop, data, event.rowIndex);
						var sumMchAmt = AUIGrid.getFooterData(auiGridLeftTop)[5].text;
						$M.setValue("result_mch_amt", sumMchAmt);
						calcAmt();
					}
				}
			});	

			$("#total_cnt1").html(AUIGrid.getGridData(auiGridLeftTop).length);
			
			var sumDelayAmt = AUIGrid.getFooterData(auiGridLeftTop)[4].text;
			$M.setValue("result_delay_amt", sumDelayAmt);
			
			var sumMchAmt = AUIGrid.getFooterData(auiGridLeftTop)[5].text;
			$M.setValue("result_mch_amt", sumMchAmt);
			
 		    // 구해진 칼럼 사이즈를 적용 시킴.
// 			var colSizeList = AUIGrid.getFitColumnSizeList(auiGridLeftTop, true);
// 		    AUIGrid.setColumnSizeList(auiGridLeftTop, colSizeList);
		}
		
		//그리드생성
		function createAUIGridLeftBottom() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
				showFooter : true,
				footerPosition : "top",
				enableMovingColumn : false,
// 				// fixedColumnCount : 5,
			};
			var columnLayout = [
				{
					dataField : "machine_doc_no",
					visible : false
				},
				{
					headerText : "차주명", 
					dataField : "cust_name", 
					width : "120",
					minWidth : "30",
					style : "aui-center"
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "160",
					minWidth : "30",
					style : "aui-left aui-popup"
				},
				{ 
					headerText : "출하일", 
					dataField : "out_dt", 
					width : "65",
					minWidth : "30",
					dataType : "date",  
					formatString : "yy-mm-dd",
					style : "aui-center",
				},
				{
					dataField : "handover_dt",
					headerText : "DI일자",
					width : "65",
					minWidth : "30",
					dataType : "date",  
					formatString : "yy-mm-dd",
					style : "aui-right",
				},
				{
					headerText : "실적",
					children : [
						{
							dataField : "sale_commission_amt",
							headerText : "판매수수료",
							width : "120",
							minWidth : "30",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						}, 
						{
							dataField : "incentive_amt",
							headerText : "인센티브",
							width : "100",
							minWidth : "30",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						},
						{
							dataField : "deduct_amt",
							headerText : "삭감액",
							width : "100",
							minWidth : "30",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						}
					]
				}, 
				{
					headerText : "지급예정",
					children : [
						{
							dataField : "pay_salemoney",
							headerText : "수수료",
							width : "120",
							minWidth : "30",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						}, 
						{
							dataField : "pay_vat_amt",
							headerText : "부가세",
							width : "100",
							minWidth : "30",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						}
					]
				},
        {
          headerText : "장비인수증",
          dataField : "accep_file_yn",
          labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
            if (value == "N") {
              return "";
            } else {
              return "제출";
            }
          },
          renderer : { // HTML 템플릿 렌더러 사용
            type : "TemplateRenderer"
          },
          width : "80",
          minWidth : "60",
        }, 
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "out_dt",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "sale_commission_amt",
					positionField : "sale_commission_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "incentive_amt",
					positionField : "incentive_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
// 				{
// 					dataField : "di_coupon_amt",
// 					positionField : "di_coupon_amt",
// 					operation : "SUM",
// 					formatString : "#,##0",
// 					style : "aui-right aui-footer",
// 				},
				{
					dataField : "deduct_amt",
					positionField : "deduct_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "pay_salemoney",
					positionField : "pay_salemoney",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "pay_vat_amt",
					positionField : "pay_vat_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
			];
			
			auiGridLeftBottom = AUIGrid.create("#auiGridLeftBottom", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGridLeftBottom, footerColumnLayout);
			AUIGrid.setGridData(auiGridLeftBottom, ${payCommissionList});
			$("#auiGridLeftBottom").resize();
			
			// 발주내역 클릭시 -> 발주서상세 팝업 호출
			AUIGrid.bind(auiGridLeftBottom, "cellClick", function(event) {
				if(event.dataField == "machine_name" ) {
					var params = {
						"machine_doc_no" : event.item.machine_doc_no
					};
					var popupOption = "";
					$M.goNextPage('/sale/sale0101p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
			$("#total_cnt2").html(AUIGrid.getGridData(auiGridLeftBottom).length);
			
			// 지급예정 - 수수료 세팅
			var payCommission = AUIGrid.getFooterData(auiGridLeftBottom)[4].text;
// 			console.log("payCommission : ", payCommission.replace(/,/g, ''));
			
			$M.setValue("pay_commission", payCommission);
			// 지급예정 - 부가세 세팅
			var payVat = AUIGrid.getFooterData(auiGridLeftBottom)[5].text;
			$M.setValue("pay_vat", payVat);
			
			// 구해진 칼럼 사이즈를 적용 시킴.
// 			var colSizeList = AUIGrid.getFitColumnSizeList(auiGridLeftBottom, true);
// 			AUIGrid.setColumnSizeList(auiGridLeftBottom, colSizeList);
		}
		
		
		//그리드생성
		function createAUIGridRight() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: false,
				editable : true,
				enableMovingColumn : false
			};
			var columnLayout = [
				{
					dataField : "cust_no",
					visible : false
				},
				{
					headerText : "미수년월", 
					dataField : "pay_dt", 
					width : "90",
					minWidth : "30",
					dataType : "date",  
					formatString : "yy-mm-dd",
					style : "aui-center aui-popup",
					editable : false
				},
				{ 
					headerText : "미수금", 
					dataField : "ed_misu_amt", 
					width : "205",
					minWidth : "30",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false
				},
				{ 
					headerText : "정산예정", 
					dataField : "calc_amt", 
					dataType : "numeric",
					width : "205",
					minWidth : "30",
					formatString : "#,##0",
					style : "aui-right",
					editable : true,
					styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if ($M.getValue("agency_pay_status_cd") != "") {
							return null;
						} else {
							return "aui-editable";
						}
					},
// 					expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
// 						// 정산예정 계산
// 						// 지급예정 합계 - 정산명세 지연금 - 기타 > 부품미수금   : 부품미수금
// 						//                            else 계산된 금액
// 						console.log(item);
// 						var val = item.calc_amt;  // 정산예정
// 						console.log($M.getValue("agency_pay_status_cd"));
						
// 						var payTotalAmt = $M.getValue("pay_total_amt"); 		// 지급예정 합계 
// 						var resultDelayAmt = $M.getValue("result_delay_amt");   // 정산명세 지연금
// 						var resultEtcAmt = $M.getValue("result_etc_amt");       // 기타
// 						var edMisuAmt = item.ed_misu_amt;  // 부품 미수금
						
// 						var calcVal = Number(payTotalAmt) - Number(resultDelayAmt) - Number(resultEtcAmt);
						
// 						console.log("합계 : ", calcVal);
// 						console.log("미수금 : ", edMisuAmt);
// 						if ($M.getValue("agency_pay_status_cd") == "") {
// 							if (calcVal > edMisuAmt) {
// 								val = edMisuAmt;
// 							} else {
// 								val = calcVal;
// 							}
// 						}
							
// 						return val; 

// // 						var val = 0;
// // 						var resultTotalAmt = $M.getValue("result_total_amt");  // 정산명세 합계
// // 						var payTotalAmt = $M.getValue("pay_total_amt"); // 지급예정 합계
// // 						var resultDelayAmt = $M.getValue("result_delay_amt"); // 정산명세 지연금
// // 						var resultEtcAmt = $M.getValue("result_etc_amt"); // 정산명세 기타
// // 						var edMisuAmt = item.ed_misu_amt;  // 부품 미수금
// // 						var calcAmt = item.calc_amt;  // 정산예정
// // 						var partAmt = 0;
						
// // 						// 정산명세의 합계가 지급예정의 합계보다 크다면
// // 						if (resultTotalAmt > payTotalAmt) {
// // 							$M.setValue("result_part_amt", payTotalAmt - resultDelayAmt);
// // 							partAmt = payTotalAmt - resultDelayAmt;
							
// // 							if (edMisuAmt != 0) {
// // 								if ($M.getValue("result_part_amt") > 0) {
// // 									if (edMisuAmt > partAmt) {
// // 										val = partAmt;
// // 										partAmt = 0;
// // 									} else {
// // 										if (partAmt != 0) {
// // 											val = edMisuAmt;
// // 											partAmt = partAmt - edMisuAmt; 
// // 										} else {
// // 											val = 0;
// // 										}
// // 									}
// // 								}
// // 							}
							
// // // 							$M.setValue("result_total_amt", );
// // 						} else {
// // 							var misuAmt = 0;
// // 							var sum = 0;
// // 							if (edMisuAmt != 0) {
// // 								val = edMisuAmt;
// // 								misuAmt = edMisuAmt;
// // 								sum = sum + calcAmt;
// // 							}
							
// // 							var ruleMoney = payTotalAmt - resultDelayAmt - resultEtcAmt; 
// // 							if (ruleMoney <= sum) {
// // 								sum = ruleMoney;
// // 								val = sum;
// // 							}
							
// // 							$M.setValue("result_part_amt", sum);
// // // 							$M.setValue("result_total_amt", );
// // 						}
// // 						return val;
// 					}
				}
			];
			
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setGridData(auiGridRight, ${payPartList});
			$("#auiGridRight").resize();
			// 발주내역 클릭시 -> 발주서상세 팝업 호출
			AUIGrid.bind(auiGridRight, "cellClick", function(event) {
				var params = {
						"s_cust_no" : event.item.cust_no,
						"s_end_dt" : event.item.pay_dt,
						"s_agency_yn" : "Y"
				};
				if(event.dataField == "pay_dt" ) {
					openDealLedgerPanel($M.toGetParam(params));
				}
			});	
			
			// 미수금 - 부품 세팅
			if (AUIGrid.getGridData(auiGridRight).length > 0) {
				var misuPart = AUIGrid.getGridData(auiGridRight)[0].ed_misu_amt;
				$M.setValue("misu_part", Number(misuPart));
	// 			$M.setValue("misu_part", 0);
			}
			
			calcAmt();
			AUIGrid.bind(auiGridRight, "cellEditEnd", function(event) {
				if(event.dataField == "calc_amt" ) {
					// 정산명세 - 장비
					$M.setValue("misu_part", event.item.calc_amt);
					$M.setValue("result_part_amt", event.item.calc_amt);
					calcAmt();
				}
			});

			AUIGrid.bind(auiGridRight, "cellEditBegin", function(event) {
				console.log(event);
				if ($M.getValue("agency_pay_status_cd") != "") {
					if(event.dataField == "calc_amt") {
						return false;
					}
				}
			});
		}
		
		// 금액 계산관련 함수
		function calcAmt() {
			// 정산명세 - 부품 세팅
			if (AUIGrid.getGridData(auiGridRight).length > 0) {
				var calcAmt = AUIGrid.getGridData(auiGridRight)[0].calc_amt;
				$M.setValue("result_part_amt", calcAmt);
			}

			// 정산명세 - 합계 세팅
			var calcDelayAmt = $M.getValue("result_delay_amt");
			var calcEtcAmt = $M.getValue("result_etc_amt");
			var calcPartAmt = $M.getValue("result_part_amt");
			var calcMchAmt = $M.getValue("result_mch_amt");
			$M.setValue("result_total_amt", Number(calcDelayAmt) + Number(calcEtcAmt) + Number(calcPartAmt) + Number(calcMchAmt));
			
			// 지급예정 - 합계 세팅
			var payCommission = $M.getValue("pay_commission");
			var payVat = $M.getValue("pay_vat");
			var Claims = $M.getValue("as_money");
			$M.setValue("pay_total_amt", Number(payCommission) + Number(payVat) + Number(Claims));
			
			// 미수금 - 장비 세팅  - 장비 미결재금 + 지연금
			var misuMch = AUIGrid.getFooterData(auiGridLeftTop)[1].value + AUIGrid.getFooterData(auiGridLeftTop)[2].value;
			$M.setValue("misu_mch", misuMch);

			var misuPart = $M.getValue("misu_part"); // 미수금 - 부품
			var misuEtc = $M.getValue("misu_etc");  // 미수금 - 기타
			var misuMch = $M.getValue("misu_mch");  // 미수금 - 장비
			// 미수금 - 합계 세팅
			$M.setValue("misu_total_amt", Number(misuMch) + Number(misuPart) + Number(misuEtc));
			
			// 실지급예정 세팅
			var payTotalAmt = $M.getValue("pay_total_amt"); // 지급예정 합계
			var calcTotalAmt = $M.getValue("result_total_amt"); // 정산명세 합계
			
			if (payTotalAmt - calcTotalAmt < 0) {
				$M.setValue("total_pay_amt", 0);
			} else {
				$M.setValue("total_pay_amt", payTotalAmt - calcTotalAmt);
			}
		}
		
		// 클레임 처리내역 팝업 호출
		function goClaimsPopup() {
			var params = {
					pay_dt : $M.getValue("pay_dt"),
					org_code : $M.getValue("org_code"),
			}
			var popupOption = "";
			$M.goNextPage('/acnt/acnt0402p04', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		// 미수금내역 팝업 호출
		function goUnCollectMoneyPopup() {
// 			var params = {
// 					pay_dt : $M.getValue("pay_dt"),
// 					org_code : $M.getValue("org_code"),
// 			}
// 			var popupOption = "";
// 			// acnt0402p02
// 			$M.goNextPage('/acnt/acnt0402p05', $M.toGetParam(params), {popupStatus : popupOption});
			var params = {
					agency_org_code : $M.getValue("org_code"),
					search_gubun_mon : "Y",
					search_gubun_all : "Y"
			}
			var popupOption = "";
			$M.goNextPage('/acnt/acnt0402p02', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		// 닫기
		function fnClose() {
			window.close();
		}
		
		// 인쇄
		function goPrint() {
			var data = {
				"org_name" : "${orgName}" + " [" + "${orgCustName}" + "]"
				, "pay_year" : $M.getValue("pay_year")
				, "pay_mon" : $M.getValue("pay_mon")
				, "agency_pay_status_name" : "【 "+$M.getValue("agency_pay_status_name")+" 】"
				, "after_amt" : $M.nvl($M.getValue("after_amt"), "0")
				, "pay_commission" : $M.nvl($M.getValue("pay_commission"), "0")
				, "pay_vat" : $M.nvl($M.getValue("pay_vat"), "0")
				, "as_money" : $M.nvl($M.getValue("as_money"), "0")
				, "pay_total_amt" : $M.nvl($M.getValue("pay_total_amt"), "0")
				, "result_delay_amt" : $M.nvl($M.getValue("result_delay_amt"), "0")
				, "result_etc_amt" : $M.nvl($M.getValue("result_etc_amt"), "0")
				, "result_part_amt" : $M.nvl($M.getValue("result_part_amt"), "0")
				, "result_mch_amt" : $M.nvl($M.getValue("result_mch_amt"), "0")
				, "result_total_amt" : $M.nvl($M.getValue("result_total_amt"), "0")
				, "misu_mch" : $M.nvl($M.getValue("misu_mch"), "0")
				, "misu_part" : $M.nvl($M.getValue("misu_part"), "0")
				, "misu_etc" : $M.nvl($M.getValue("misu_etc"), "0")
				, "misu_total_amt" : $M.nvl($M.getValue("misu_total_amt"), "0")
				, "total_pay_amt" : $M.nvl($M.getValue("total_pay_amt"), "0")
				, "remark" : $M.getValue("remark")
			}
			var param = {
				"data" : data
			}
			openReportPanel('acnt/acnt0402p03_01.crf', param);	
		}
		
		// 결재처리
		function goApproval(val) {
			var msg = "결재하시겠습니까 ?";
			var saveMode = "appr";
			var allReturnYn = "N";
			
			if (val == "return") {
				msg = "반려하시겠습니까 ?";
				saveMode = "return";
				
				if ($M.getValue("login_org_code") == $M.getValue("org_code")) {
					allReturnYn = "Y";
				}
			}
			
			var statusCd = $M.getValue("agency_pay_status_cd");
			
			var apprMemNo;
			var apprDate;
			if (saveMode == "return") {
				switch (statusCd) {
				case "2" :
					apprMemNo = $M.getValue("app_mem_no");
					apprDate = $M.getValue("app_date");
					break;
				case "3" :
					apprMemNo = $M.getValue("chk_mem_no");
					apprDate = $M.getValue("chk_date");
					break;
				case "9" :
					apprMemNo = $M.getValue("pay_mem_no");
					apprDate = $M.getValue("pay_date");
					break;
				}
			}
			
			var param = {
					agency_pay_no : $M.getValue("agency_pay_no"),
					agency_pay_status_cd : $M.getValue("agency_pay_status_cd"),
					pay_dt : $M.getValue("pay_dt"),
					org_code : $M.getValue("org_code"),
					result_part_amt : $M.getValue("result_part_amt"),
					save_mode : saveMode,
					all_return_yn : allReturnYn,
					appr_mem_no : apprMemNo,
					appr_date : apprDate
			}
			
			$M.goNextPageAjaxMsg(msg, this_page + "/appr", $M.toGetParam(param) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("처리가 완료되었습니다.");
 		    			window.opener.goSearch();
 		    			fnClose();
					}
				}
			);	
		}
		
		// 반려
		function goApprReturn() {
			goApproval('return');
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="login_org_code" name="login_org_code" value="${loginOrgCode}">
<input type="hidden" id="pay_dt" name="pay_dt" value="${inputParam.pay_dt}">
<input type="hidden" id="org_code" name="org_code" value="${inputParam.org_code}">
<input type="hidden" id="org_name" name="org_name" value="${orgName}">
<input type="hidden" id="agency_pay_status_cd" name="agency_pay_status_cd" value="${payMaster.agency_pay_status_cd}">
<input type="hidden" id="agency_pay_status_name" name="agency_pay_status_name" value="${payMaster.agency_pay_status_name}">
<input type="hidden" id="save_mode" name="save_mode">
<input type="hidden" id="calc_amt" name="calc_amt">
<input type="hidden" id="ed_misu_amt" name="ed_misu_amt">
<input type="hidden" id="agency_pay_no" name="agency_pay_no" value="${payMaster.agency_pay_no}">
<input type="hidden" id="req_mem_no" name="req_mem_no" value="${payMaster.req_mem_no}">
<input type="hidden" id="req_mem_name" name="req_mem_name" value="${payMaster.req_mem_name}">
<input type="hidden" id="req_date" name="req_date" value="${payMaster.req_date}">
<input type="hidden" id="app_mem_no" name="app_mem_no" value="${payMaster.app_mem_no}">
<input type="hidden" id="app_mem_name" name="app_mem_name" value="${payMaster.app_mem_name}">
<input type="hidden" id="app_date" name="app_date" value="${payMaster.app_date}">
<input type="hidden" id="chk_mem_no" name="chk_mem_no" value="${payMaster.chk_mem_no}">
<input type="hidden" id="chk_mem_name" name="chk_mem_name" value="${payMaster.chk_mem_name}">
<input type="hidden" id="chk_date" name="chk_date" value="${payMaster.chk_date}">
<input type="hidden" id="pay_mem_no" name="pay_mem_no" value="${payMaster.pay_mem_no}">
<input type="hidden" id="pay_mem_name" name="pay_mem_name" value="${payMaster.pay_mem_name}">
<input type="hidden" id="pay_date" name="pay_date" value="${payMaster.pay_date}">
<input type="hidden" id="pay_year" name="pay_year" value="${payMaster.pay_year}">
<input type="hidden" id="pay_mon" name="pay_mon" value="${payMaster.pay_mon}">
<input type="hidden" id="pay_remark" name="pay_remark" value="${payMaster.remark}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">				
			<div>				
				<div class="title-wrap">
					<div class="left approval-left">
						<h4>${orgName}<span>&nbsp;월 정산서&nbsp;[${orgCustName}]</span></h4>	
						<div >
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>		
						</div>	
					</div>
	<!-- 결재선 -->
		<table class="table-border doc-table sm-table" style="width: 41.2%; margin-left: 10px;">
			<colgroup>
				<col width="50px">
				<col width="100px">
				<col width="100px">
				<col width="100px">
				<col width="100px">
			</colgroup>
			<tbody>
				<tr>						
					<th rowspan="2" class="title-bg th" style="padding: 6px;">
						<span class="v-align-middle" style="font-size: 12px !important;">결재선</span>
					</th>
					<c:forEach var="list" begin="1" end="4" varStatus="status">
					<th class="th">
						<div class="approval-table">
							<div class="input-area">
								<input type="text" style="width: 100%; text-align: right; margin-right: 7px;" id="apprName${status.count}" name="apprName${status.count}" value="" readonly="readonly">
								<input type="hidden" id="apprNum${status.count}" name="apprNum${status.count}" value="" readonly="readonly" class="apprLineMemNo">
								<!-- 직원검색 버튼 -->
								<c:if test="${status.count eq 1 && empty payMaster.agency_pay_status_cd}">
									<button type="button" class="icon-btn-search" onclick="javascript:__fnMemListPopup(this.value)" value="${status.count}" id="btnSearch${status.count}"> <i class="material-iconssearch"> </i></button>
								</c:if>
								<!-- /직원검색 버튼 -->
							</div>
							<c:if test="${status.count eq 1 && empty payMaster.agency_pay_status_cd  }">
							<div class="delete-area">
								<button type="button" class="icon-btn-close" onclick="javascript:__fnMemNameDel(this.value)" value="${status.count}" id="btnDelete${status.count}"><i class="material-iconsclose"></i></button>
							</div>
							</c:if>
						</div>
					</th>
					</c:forEach>
				</tr>
				<tr>				
					<c:forEach var="list" begin="1" end="4" varStatus="status">
						<td class="text-center td" id="apprStatus${status.count}" name="apprStatus${status.count}" style="font-size: 12px !important;"></td>
					</c:forEach>
				</tr>
			</tbody>			
		</table>
		<!-- /5dt div -->
	<input type="hidden" name="appr_job_cd" id="appr_job_cd" value="${apprBean.appr_job_cd}" alt="결재업무" required="required"/>
	<input type="hidden" name="appr_status_cd" id="appr_proc_status" value="${apprBean.appr_proc_status_cd}" alt="작업상태" required="required"/>
	<input type="hidden" name="appr_mem_no_str" id="appr_mem_no_str" alt="결재라인" required="required"/>
	<!-- /결재선 -->
				</div>			
				<div class="row">
					<div class="col-8">
<!-- 미수금현황[장비] -->
						<div>
							<div class="title-wrap mt10">
								<h4>미수금현황[장비]</h4>	
							</div>
							<div id="auiGridLeftTop" style="margin-top: 5px; height: 320px;"></div>
							<div class="btn-group mt10">
								<div class="left">
									총 <strong id="total_cnt1" class="text-primary">0</strong>건
								</div>
							</div>
						</div>
<!-- /미수금현황[장비] -->		
<!-- 미지급현황 -->
						<div>
							<div class="title-wrap mt10">
								<h4>미지급현황</h4>	
							</div>
							<div id="auiGridLeftBottom" style="margin-top: 5px; height: 320px;"></div>
							<div class="btn-group mt10">
								<div class="left">
									총 <strong id="total_cnt2" class="text-primary">0</strong>건
								</div>
							</div>
						</div>
<!-- /미지급현황 -->		
					</div>
					<div class="col-4">
<!-- 미수금현황[부품] -->
						<div>
							<div class="title-wrap mt10">
								<h4>미수금현황[부품]</h4>	
							</div>
							<div id="auiGridRight" style="margin-top: 5px; height: 55px;"></div>
						</div><br>
<!-- /미수금현황[부품] -->
						<div class="row">
							<div class="col-4">
<!-- 지급예정 -->
								<div>
									<div class="title-wrap mt10">
										<h4>지급예정</h4>	
										<div class="btn-group">
											<div class="right">
												<button type="button" class="btn btn-default" onclick="javascript:goClaimsPopup();">클레임처리내역</button>
											</div>
										</div>
									</div>
									<table class="table-border mt5">
										<colgroup>
											<col width="50px">
											<col width="">
										</colgroup>
										<tbody>
											<tr>
												<th class="text-right">전월<br>이월</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width90px">
															<input type="text" class="form-control text-right" id="after_amt" name="after_amt" readonly format="decimal" datatype="int">
														</div>
														<div class="col width16px">원</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">수수료</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width90px">
															<input type="text" class="form-control text-right" id="pay_commission" name="pay_commission" readonly format="decimal" datatype="int">
														</div>
														<div class="col width16px">원</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">부가세</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width90px">
															<input type="text" class="form-control text-right" id="pay_vat" name="pay_vat" readonly format="decimal" datatype="int">
														</div>
														<div class="col width16px">원</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">클레임</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width90px">
															<input type="text" class="form-control text-right" id="as_money" name="as_money" value="${payAsMoney.asmoney}" readonly format="decimal" datatype="int">
														</div>
														<div class="col width16px">원</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">합계</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width90px">
															<input type="text" class="form-control text-right" id="pay_total_amt" name="pay_total_amt" readonly format="decimal" datatype="int">
														</div>
														<div class="col width16px">원</div>
													</div>
												</td>
											</tr>					
										</tbody>
									</table>
								</div>
<!-- /지급예정 -->		
							</div>
							<div class="col-4">
<!-- 정산명세 -->
								<div>
									<div class="title-wrap mt10">
										<h4>정산명세</h4>	
									</div>
									<table class="table-border mt5">
										<colgroup>
											<col width="50px">
											<col width="">
										</colgroup>
										<tbody>
											<tr>
												<th class="text-right">지연금</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width90px">
<%-- 															<input type="text" class="form-control text-right" id="result_delay_amt" name="result_delay_amt" value="${payMaster.result_delay_amt}" readonly format="decimal" datatype="int"> --%>
															<input type="text" class="form-control text-right" id="result_delay_amt" name="result_delay_amt" readonly format="decimal" datatype="int">
														</div>
														<div class="col width16px">원</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">기타</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width90px">
															<input type="text" class="form-control text-right" id="result_etc_amt" name="result_etc_amt" value="${payEtcMoney.etcmoney}" readonly format="decimal" datatype="int">
														</div>
														<div class="col width16px">원</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">부품</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width90px">
															<input type="text" class="form-control text-right" id="result_part_amt" name="result_part_amt" value="${payMaster.result_part_amt}" readonly format="decimal" datatype="int">
														</div>
														<div class="col width16px">원</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">장비</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width90px">
															<input type="text" class="form-control text-right" id="result_mch_amt" name="result_mch_amt" value="${payMaster.result_mch_amt}" readonly format="decimal" datatype="int">
														</div>
														<div class="col width16px">원</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">합계</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width90px">
															<input type="text" class="form-control text-right" id="result_total_amt" name="result_total_amt" readonly format="decimal" datatype="int">
														</div>
														<div class="col width16px">원</div>
													</div>
												</td>
											</tr>					
										</tbody>
									</table>
								</div>
<!-- /정산명세 -->	
							</div>
							<div class="col-4">
<!-- 미수금 -->
								<div>
									<div class="title-wrap mt10">
										<h4>미수금</h4>	
										<div class="btn-group">
											<div class="right">
												<button type="button" class="btn btn-default" onclick="javascript:goUnCollectMoneyPopup();">미수금내역</button>
											</div>
										</div>
									</div>
									<table class="table-border mt5">
										<colgroup>
											<col width="40px">
											<col width="">
										</colgroup>
										<tbody>
											<tr>
												<th class="text-right">장비</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width100px">
															<input type="text" class="form-control text-right" id="misu_mch" name="misu_mch" readonly format="decimal" datatype="int">
														</div>
														<div class="col width16px">원</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">부품</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width100px">
															<input type="text" class="form-control text-right" id="misu_part" name="misu_part" readonly format="decimal" datatype="int">
														</div>
														<div class="col width16px">원</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">기타</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width100px">
															<input type="text" class="form-control text-right" id="misu_etc" name="misu_etc" value="${payEtcMoney.etcmoney}" readonly format="decimal" datatype="int">
														</div>
														<div class="col width16px">원</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">합계</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width100px">
															<input type="text" class="form-control text-right" id="misu_total_amt" name="misu_total_amt" readonly format="decimal" datatype="int">
														</div>
														<div class="col width16px">원</div>
													</div>
												</td>
											</tr>					
										</tbody>
									</table>
								</div>
<!-- /미수금 -->	
							</div>
						</div>
<!-- 실 지급예정 -->
						<div>
							<div class="title-wrap mt10">
								<h4>실 지급예정</h4>	
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width140px">
													<input type="text" class="form-control text-right" id="total_pay_amt" name="total_pay_amt" readonly format="decimal" datatype="int">
												</div>
												<div class="col width16px">원</div>
											</div>
										</td>
									</tr>					
								</tbody>
							</table>
						</div>
<!-- /실 지급예정 -->		
<!-- 비고(출하) -->
						<div>
							<div class="title-wrap mt10">
								<h4>비고(출하)</h4>	
							</div>
							<div>
								<textarea class="form-control" style="height: 125px;"  id="note_txt" name="note_txt" readonly><c:forEach var="item" items="${noteTxtList}">${item.note_txt}
</c:forEach></textarea>
							</div>
						</div>
<!-- /비고(출하) -->
<!-- 비고(쓰기) -->
						<div>
							<div class="title-wrap mt10">
								<h4>비고(쓰기)</h4>	
							</div>
							<div>
								<textarea class="form-control" style="height: 125px;" id="remark" name="remark"></textarea>
							</div>
						</div>
<!-- /비고(쓰기) -->					
					</div>
				</div>
			</div>
			<div class="btn-group mt10">
				<div class="right">
<!-- 					<button type="button" class="btn btn-success" onclick="javascript:alert('결재');">결재</button> -->
<!-- 					<button type="button" class="btn btn-success" onclick="javascript:alert('반려');">반려</button> -->
<!-- 					<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button> -->
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>