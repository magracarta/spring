<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 장비입금관리 > null > 입금현황
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-28 09:08:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var machinePayTypeJson = JSON.parse('${codeMapJsonObj["MACHINE_PAY_TYPE"]}');
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			fnInitPage();
		});
		
		function fnInitPage() {
			var info = ${info}
			fnSetData(info);
		}
		
		function fnSetData(result) {
			 $M.setValue(result.basicInfo);
			 $M.setValue("machine_name_temp", $M.getValue("machine_name"));
			 if (result.basicInfo.hp_no != null) {
				 $M.setValue("hp_no", $M.phoneFormat(result.basicInfo.hp_no));	
			 }
			 if (result.basicInfo.doc_hp_no != null) {
				 $M.setValue("doc_hp_no", $M.phoneFormat(result.basicInfo.doc_hp_no));	
			 }
			 // 결제조건
			 // TODO: CD_MACHINE_PAY_TYPE 어음 코드 넣기
			 if (result.planList != null) {
	        	 var planList = result.planList;
	        	 console.log(planList);
	        	 var payTypes = ["CASH", "CARD", "USED","FINANCE", "ASSIST", "VAT"];
	        	 console.log(planList);
	        	 for (var i = 0; i < planList.length; ++i) {
	        		 var j = payTypes.indexOf(planList[i].machine_pay_type_cd);
	        		 if (j != -1) {
	        			 var jsonVariable = {};
	        			 jsonVariable['plan_amt_'+j] = planList[i].plan_amt;
	        			 jsonVariable['plan_dt_'+j] = planList[i].plan_dt;
	        			 jsonVariable['deposit_amt_'+j] = planList[i].deposit_amt;
	        			 jsonVariable['misu_amt_'+j] = planList[i].misu_amt;
	        			 $M.setValue(jsonVariable);
	        		 }
 	        		 if(planList[i].misu_amt != 0) {
	        				$("#deposit_btn_"+j).removeClass("dpn");
	        		 }
	        	 }
			 }
			 AUIGrid.setGridData("#auiGrid", result.depositList);
			AUIGrid.setAllCheckedRows(auiGrid, true);
				
			 <%--if("${SecureUser.org_type}" == "AGENCY") {--%>
			 if(${page.fnc.F00802_001 eq 'Y'}) {
				 $(".agency-yn").addClass("dpn");
			 }

			// 2022-12-07 황빛찬 (SR : 14503) 유상부품대 연동 추가.
			 var partCostMap = result.partCostMap;
			 var resultPartCostAmt = partCostMap.result_amt; // 유상부품대 남은 금액 (입금 해야 할 금액)
			 if (partCostMap.part_cost_in_amt == "") {
				 resultPartCostAmt = partCostMap.part_cost_amt;
			 }

			 $M.setValue("result_part_cost_amt", resultPartCostAmt);
			 if (resultPartCostAmt != 0) {
				 $("#partCostBtn").removeClass("dpn");
				 $("#result_part_cost_amt").css("color", "red");
			 }
			 
			 fnTotalDepositPrice();
			 fnTotalMisuPrice();
		}
		
		function fnTotalDepositPrice() {
			var sum = 0;
			$('.deposit-amt').each(function(){ 
				sum += $M.toNum($(this).val()); 
			});
			$M.setValue("total_deposit_amt", sum);
		}
		
		function fnTotalMisuPrice() {
			var sum = 0;
			$('.misu-amt').each(function(){ 
				sum += $M.toNum($(this).val()); 
			});
			$M.setValue("total_misu_amt", sum);
		}
		
		function goDepositProcess(machinePayType) {
			var params = {
					"machine_doc_no" : $M.getValue("machine_doc_no"),
					"cust_no" : $M.getValue("cust_no"),
					"amt" : $M.getValue("amt"),
					"view" : $M.getValue("view"),
					"body_no" : $M.getValue("body_no"),
					"machine_pay_type_cd" : machinePayType
			};
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=450, left=0, top=0";
			$M.goNextPage('/cust/cust0301p02', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "machine_deposit_result_seq",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
				// 체크박스 표시 설정
				showRowCheckColumn : true,
			};
			var columnLayout = [
				{
					dataField : "machine_deposit_result_seq",
					visible : false
				},
				{
					dataField : "machine_doc_no",
					visible : false
				},
				{ 
					dataField : "machine_pay_type_cd", 
					visible : false
				},
				{ 
					dataField : "acc_type_cd", 
					visible : false
				},
				{
					headerText : "확인일자", 
					dataField : "deposit_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd", 
					width : "10%",
					style : "aui-center aui-popup"
				},
				{ 
					headerText : "결제방식", 
					dataField : "acc_type_name", 
					width : "8%",
					style : "aui-center",
				},
				{ 
					headerText : "비고", 
					dataField : "deposit_text", 
					style : "aui-left",
				},
				{ 
					headerText : "입금액", 
					dataField : "calc_deposit_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%",
					style : "aui-right",
				},
				{ 
					headerText : "장비대", 
					dataField : "deposit_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%",
					style : "aui-right",
				},
				{ 
					headerText : "지연금", 
					dataField : "delay_amt", 
					dataType : "numeric",
					formatString : "#,##0", 
					width : "10%",
					style : "aui-right",
				},
				{ 
					headerText : "처리자", 
					dataField : "reg_mem_name", 
					width : "10%",
					style : "aui-center",
				},
				{ 
					headerText : "처리일시", 
					dataField : "reg_date", 
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
					width : "15%",
					style : "aui-center",
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "deposit_dt" ) {
					var params = {
							"machine_deposit_result_seq" : event.item["machine_deposit_result_seq"]
					};
					console.log(params);
					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=450, left=0, top=0";
					$M.goNextPage('/cust/cust0301p05', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
		}
	
		// 받을어음관리 데이터 콜백
		function fnSetDepositInfo(data) {
			opener.fnSetDepositInfo(data);
			fnClose();
		}
		
		// 문자발송 팝업
		function fnSendSms() {
			
			//메세지참조기능 사용시 사용메뉴seq,파라미터도 세팅		
			var param = {
					   'name' 		 : $M.getValue("cust_name"), 
					   'hp_no' 		 : $M.getValue("hp_no"),
					   'req_msg_yn'  : "Y",
					   'menu_seq'	 : ${menu_seq},
					   'menu_param'  :  $M.getValue("machine_doc_no")
			   }
			
			openSendSmsPanel($M.toGetParam(param));
		}
		
		
		
		function fnClose() {
			window.close();
		}

		function goPrintDeposit() {
			// 3-1차 그리드 전체 데이터
			// var listData = AUIGrid.getGridData(auiGrid);

			// 3-2차 체크된것만 출력
			var listData = AUIGrid.getCheckedRowItemsAll(auiGrid);
			for(var i in listData) {
				listData[i].rowNo = Number(i)+1;
			}
			var depositAmtSum = 0;
			for(var i in listData) {
				depositAmtSum += listData[i].calc_deposit_amt;
			}
			var data = {
				"cust_name" : $M.getValue("cust_name")
				, "mem_name" : "${SecureUser.kor_name}"
				, "deposit_memo" : ""
				, "yk_info" : ${ykInfo}
				, "amt_sum" : $M.setComma(depositAmtSum) + " 원"
			};
			var param = {
				"data" : data
				, "list" : listData
			}
			// 3-1차
			// openReportPanel('cust/cust0301p01.crf',param);

			// 3-2차
			openReportPanel('cust/cust0301p01_v32.crf',param);
		}

		// 2022-12-07 (SR : 14503) 유상부품대 연동 추가.
		function goInoutPopup() {
			if (confirm("입금처리 하시겠습니까?") == false) {
				return false;
			}

			var popupOption = "";
			// 입출금전표처리
			var param = {
				"cust_no" : $M.getValue("cust_no"),
				"machine_doc_no" : $M.getValue("machine_doc_no"),
				"popup_yn" : "Y",
				"result_part_cost_amt" : $M.getValue("result_part_cost_amt") // 입금가능한 남은 유상부품대
			};

			$M.goNextPage('/cust/cust020301', $M.toGetParam(param), {popupStatus : popupOption});
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="doc_mem_no" name="doc_mem_no">
<input type="hidden" id="cust_no" name="cust_no">
<input type="hidden" id="amt" name="amt" value="${inputParam.amt}"> <!-- 어음 금액 -->
<input type="hidden" id="view" name="view" value="${inputParam.view}"> <!-- 어음 구분 파라미터 -->
<input type="hidden" id="parent_js_name" name="parent_js_name" value="${inputParam.parent_js_name}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>				
				<table class="table-border mt5">
					<colgroup>
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">관리번호</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control" readonly="readonly" id="machine_doc_no" name="machine_doc_no">
									</div>
								</div>
							</td>
							<th class="text-right">처리일자</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control" readonly="readonly" id="reg_date" name="reg_date" dateFormat="yyyy-MM-dd">
									</div>
								</div>
							</td>
							<th class="text-right">상품명</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control" readonly="readonly" id="machine_name" name="machine_name">
									</div>
								</div>
							</td>
							<th class="text-right">합계금액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="total_vat_amt" name="total_vat_amt" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<th class="text-right">미결제액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="misu_amt" name="misu_amt" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
						</tr>	
						<tr>
							<th class="text-right">차주명</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
								<input type="text" class="form-control" readonly="readonly" id="cust_name" name="cust_name">
									</div>
								</div>
							</td>
							<th class="text-right">차주명연락처</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control" readonly="readonly" name="hp_no" format="phone">
									</div>
								</div>
							</td>
							<th class="text-right">차대번호</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
								<input type="text" class="form-control" readonly="readonly" id="body_no" name="body_no">
									</div>
								</div>
							</td>
							<th class="text-right">입금액계</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="deposit_amt" name="deposit_amt" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<th class="text-right">미결이자</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="miijamoney" name="miijamoney" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
						</tr>	
						<tr>
							<th class="text-right">판매자</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
								<input type="text" class="form-control" readonly="readonly" id="doc_mem_name" name="doc_mem_name">
									</div>
								</div>
							</td>
							<th class="text-right">판매자연락처</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control" readonly="readonly" id="doc_hp_no" name="doc_hp_no" format="phone">
									</div>
								</div>
							</td>
							<th class="text-right">입금자명</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
								<input type="text" class="form-control" readonly="readonly" id="deposit_name" name="deposit_name">
									</div>
								</div>
							</td>
							<th class="text-right">입금은행</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control" readonly="readonly" id="bank_name" name="bank_name">
									</div>
								</div>
							</td>
							<th class="text-right">입금예정금액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="deposit_plan" name="deposit_plan">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
						</tr>					
					</tbody>
				</table>
			</div>
<!-- /폼테이블-->	
<!-- 입금내역 -->
			<div>
				<div class="title-wrap mt10">
					<h4>입금내역</h4>					
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="14.2857%">
						<col width="14.2857%">
						<col width="14.2857%">
						<col width="14.2857%">
						<col width="14.2857%">
						<col width="14.2857%">
						<col width="14.2857%">
						<col width="14.2857%">
					</colgroup>
					<thead>
						<tr>
							<th>구분</th>
							<th>현금</th>
							<th>카드</th>
							<th>중고</th>
							<th>금융</th>
							<th>보조</th>
							<th>부가세</th>
							<th>미납지연금</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<th></th>
							<td>
<%--								<div class="form-row inline-pd">--%>
<%--									<div class="col-10">--%>
<%--										<input type="text" class="form-control width120px" readonly="readonly" id="plan_dt_0" name="plan_dt_0" dateFormat="yyyy-MM-dd">--%>
<%--									</div>--%>
<%--								</div>--%>
							</td>
							<td>
<%--								<div class="form-row inline-pd">--%>
<%--									<div class="col-10">--%>
<%--										<input type="text" class="form-control width120px" readonly="readonly" id="plan_dt_1" name="plan_dt_1" dateFormat="yyyy-MM-dd">--%>
<%--									</div>--%>
<%--								</div>--%>
							</td>
							<td>
<%--								<div class="form-row inline-pd">--%>
<%--									<div class="col-10">--%>
<%--										<input type="text" class="form-control width120px" readonly="readonly" id="plan_dt_2" name="plan_dt_2" dateFormat="yyyy-MM-dd">--%>
<%--									</div>--%>
<%--								</div>--%>
							</td>
							<td>
<%--								<div class="form-row inline-pd">--%>
<%--									<div class="col-10">--%>
<%--										<input type="text" class="form-control width120px" readonly="readonly" id="plan_dt_3" name="plan_dt_3" dateFormat="yyyy-MM-dd">--%>
<%--									</div>--%>
<%--								</div>--%>
							</td>
							<td>
<%--								<div class="form-row inline-pd">--%>
<%--									<div class="col-10">--%>
<%--										<input type="text" class="form-control width120px" readonly="readonly" id="plan_dt_4" name="plan_dt_4" dateFormat="yyyy-MM-dd">--%>
<%--									</div>--%>
<%--								</div>--%>
							</td>
							<td>
<%--								<div class="form-row inline-pd">--%>
<%--									<div class="col-10">--%>
<%--										<input type="text" class="form-control width120px" readonly="readonly" id="plan_dt_5" name="plan_dt_5" dateFormat="yyyy-MM-dd">--%>
<%--									</div>--%>
<%--								</div>--%>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="miijamoney" name="miijamoney" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th>결제예정금액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="plan_amt_0" name="plan_amt_0" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="plan_amt_1" name="plan_amt_1" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="plan_amt_2" name="plan_amt_2" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="plan_amt_3" name="plan_amt_3" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="plan_amt_4" name="plan_amt_4" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="plan_amt_5" name="plan_amt_5" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td style="background: #e9ecef;" align="center">
								합계
							</td>
						</tr>
						<tr>
							<th>결제금액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control deposit-amt text-right" readonly="readonly" id="deposit_amt_0" name="deposit_amt_0" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control deposit-amt text-right" readonly="readonly" id="deposit_amt_1" name="deposit_amt_1" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control deposit-amt text-right" readonly="readonly" id="deposit_amt_2" name="deposit_amt_2" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control deposit-amt text-right" readonly="readonly" id="deposit_amt_3" name="deposit_amt_3" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control deposit-amt text-right" readonly="readonly" id="deposit_amt_4" name="deposit_amt_4" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control deposit-amt text-right" readonly="readonly" id="deposit_amt_5" name="deposit_amt_5" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="total_deposit_amt" name="total_deposit_amt" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th>미결제액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control misu-amt text-right" style="color:red;" readonly="readonly" format="decimal" id="misu_amt_0" name="misu_amt_0">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control misu-amt text-right" style="color:red;"  readonly="readonly" format="decimal" id="misu_amt_1" name="misu_amt_1">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control misu-amt text-right" style="color:red;"  readonly="readonly" id="misu_amt_2" name="misu_amt_2" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control misu-amt text-right" style="color:red;" readonly="readonly" id="misu_amt_3" name="misu_amt_3" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control misu-amt text-right" style="color:red;"  readonly="readonly" id="misu_amt_4" name="misu_amt_4" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control misu-amt text-right" style="color:red;"  readonly="readonly" id="misu_amt_5" name="misu_amt_5" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" style="color:red;" readonly="readonly" id="total_misu_amt" name="total_misu_amt" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
						</tr>
						<tr class="text-center">
							<th>입금처리</th>
							<td>
								<button type="button" class="btn btn-default agency-yn dpn" id="deposit_btn_0" name="deposit_btn_0" onclick="javascript:goDepositProcess('CASH');">입금처리</button>
							</td>
							<td>
								<button type="button" class="btn btn-default agency-yn dpn" id="deposit_btn_1" name="deposit_btn_1" onclick="javascript:goDepositProcess('CARD');">입금처리</button>
							</td>
							<td>
								<button type="button" class="btn btn-default agency-yn dpn" id="deposit_btn_2" name="deposit_btn_2" onclick="javascript:goDepositProcess('USED');">입금처리</button>
							</td>
							<td>
								<button type="button" class="btn btn-default agency-yn dpn" id="deposit_btn_3" name="deposit_btn_3" onclick="javascript:goDepositProcess('FINANCE');">입금처리</button>
							</td>
							<td>
								<button type="button" class="btn btn-default agency-yn dpn" id="deposit_btn_4" name="deposit_btn_4" onclick="javascript:goDepositProcess('ASSIST');">입금처리</button>
							</td>
							<td>
								<button type="button" class="btn btn-default agency-yn dpn" id="deposit_btn_5" name="deposit_btn_5" onclick="javascript:goDepositProcess('VAT');">입금처리</button>
							</td>
							<td>
							</td>
						</tr>
						<!-- 2022-12-07 (SR : 14503) 유상부품대 연동 추가. -->
						<tr>
							<th>유상부품대</th>
							<td colspan="2">
								<div class="form-row inline-pd">
									<div class="col-5">
										<input type="text" class="form-control misu-amt text-right" readonly="readonly" format="decimal" id="result_part_cost_amt" name="result_part_cost_amt">
									</div>
									<div class="col-1">원</div>
									<button type="button" class="btn btn-default agency-yn dpn" id="partCostBtn" name="partCostBtn" onclick="javascript:goInoutPopup();">입금처리</button>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /입금내역 -->			
<!-- 처리내역 -->
			<div>
				<div class="title-wrap mt10">
					<h4>처리내역</h4>	
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
			</div>
<!-- /처리내역 -->
			<div class="btn-group mt10">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>