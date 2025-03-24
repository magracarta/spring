<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 받을어음관리 > null > 고객장비거래원장
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-08 18:03:57

-- 상세내역 추가 by 김태훈
-- 상세내역에 푸터 삭제함(ASIS에 합계 푸터 없고, 장비가, 부가세, 장비+부가세를 그리드에서 표기하기때문에 합계가 뻥튀기될수밖에없음..)

-- 상세내역 쿼리 수정 by 박예진
-- 쿼리 조건 수정
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGridTop;
		var auiGridBottom;
		
		$(document).ready(function () {
			createAUIGridTop();
			createAUIGridBottom();
			fnInitPage();
		});
		
		function fnInitPage() {
			var info = ${custInfo}
			var depositPlanList = ${depositPlanList}
			
			$M.setValue(info);
// 			$M.setValue("hp_no", $M.phoneFormat(info.hp_no));
			AUIGrid.setGridData("#auiGridTop", depositPlanList);
			
			var detailList = ${detailList}
			$("#total_cnt").html(detailList.length);
			var balanceAmt = 0;
			for (var i = 0; i < detailList.length; ++i) {
				if (detailList[i].seq == "0") {
					balanceAmt = balanceAmt+$M.toNum(detailList[i].sale_amt) - $M.toNum(detailList[i].deposit_amt);
					detailList[i].balance_amt = balanceAmt;
				}
			}
			AUIGrid.setGridData("#auiGridBottom", detailList);
		}
		
		function setCustInfo(data) {
			
			$M.goNextPageAjax(this_page + "/custChange/"+ data.cust_no, "", {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			$M.setValue(result.custInfo);
			    			AUIGrid.setGridData("#auiGridTop", result.depositPlanList);
			    			var detailList = result.detailList;
			    			
			    			console.log(detailList);
			    			
			    			$("#total_cnt").html(detailList.length);
			    			var balanceAmt = 0;
			    			for (var i = 0; i < detailList.length; ++i) {
			    				if (detailList[i].seq == "0") {
			    					balanceAmt = balanceAmt+$M.toNum(detailList[i].sale_amt) - $M.toNum(detailList[i].deposit_amt);
			    					detailList[i].balance_amt = balanceAmt;
			    				}
			    			}
			    			AUIGrid.setGridData("#auiGridBottom", detailList);
						}
					}
				);
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
				
			 fnTotalDepositPrice();
			 fnTotalMisuPrice();
		}
		
		
		function fnClose() {
			window.close();
		}
		
		//그리드생성
		function createAUIGridTop() {
			var gridPros = {
					rowIdField : "_$uid",
					showStateColumn : false,
					// No. 제거
					showRowNumColumn: false,
					showBranchOnGrouping : false,
					showFooter : true,
					footerPosition : "top",
					editable : false
				};
			var columnLayout = [
				{
					headerText : "품의번호", 
					dataField : "machine_doc_no", 
					style : "aui-center aui-popup",
					headerStyle : "aui-background-gray",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						   return "aui-background-gray";
					}
				},
				{ 
					headerText : "예정일", 
					dataField : "plan_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "18%",
					style : "aui-center"
				},
				{ 
					headerText : "구분", 
					dataField : "machine_pay_type_name", 
					width : "15%",
					style : "aui-center",
				},
				{ 
					dataField : "machine_pay_type_cd", 
					visible : false
				},
				{ 
					headerText : "예정금액", 
					dataField : "plan_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "16%",
					style : "aui-right",
				},
				{ 
					headerText : "입금액", 
					dataField : "deposit_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "16%",
					style : "aui-right",
				},
				{ 
					headerText : "잔액", 
					dataField : "balance_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "16%",
					style : "aui-right",
				}
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "machine_doc_no",
					style : "aui-center aui-footer",
					colSpan : 3
				}, 
				{
					dataField : "plan_amt",
					positionField : "plan_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "deposit_amt",
					positionField : "deposit_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "balance_amt",
					positionField : "balance_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGridTop, footerColumnLayout);
			AUIGrid.setGridData(auiGridTop, []);
			$("#auiGridTop").resize();
			AUIGrid.bind(auiGridTop, "cellClick", function(event) {
				if(event.dataField == "machine_doc_no" ) {
					var params = {
						"machine_doc_no" : event.item["machine_doc_no"],
						"cust_no" : $M.getValue("cust_no"),
						"amt" : "${inputParam.s_amt}",
						"view" : "bill"
					};
					var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=750, left=0, top=0";
					$M.goNextPage('/cust/cust0301p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
		}
		
		// 받을어음관리 데이터 콜백
		function fnSetDepositInfo(data) {
			opener.fnSetDepositInfo(data);
			fnClose();
		}
		
		function createAUIGridBottom() {
			var gridPros = {
				// Row번호 표시 여부
				showRowNumColumn : true,
				showFooter : true
			};
	
			var columnLayout = [
				{
					headerText : "품의번호",
					dataField : "machine_doc_no",
					width : "12%",
				},
				{
					headerText : "처리일자",
					dataField : "proc_dt",
					dataType : "date",
					width : "10%",
					formatString : "yyyy-mm-dd",
				},
				{
					headerText : "내역",
					dataField : "proc_remark",
					style : "aui-left aui-popup"
				},
				{
					headerText : "매출",
					dataField : "sale_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%",
					style : "aui-right"
				},
				{
					headerText : "입금",
					dataField : "deposit_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%",
					style : "aui-right"
				},
				{
					headerText : "잔액",
					dataField : "balance_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%",
					style : "aui-right"
				},
				{
					headerText : "비고",
					dataField : "vat_dt",
					dataType : "date",
					width : "20%",
					formatString : "yyyy-mm-dd"
				},
				{
					dataField : "datacase",
					visible : false
				},
				{
					dataField : "parameter",
					visible : false
				}
			];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridBottom, []);
			$("#auiGridBottom").resize();
	
			AUIGrid.bind(auiGridBottom, "cellClick", function(event){
				if(event.dataField == "proc_remark") {
					var param = {};
					var poppupOption = "";
					var url = "";
					if (event.item.datacase == "1") {
						url = "/sale/sale0101p03";
						param["machine_doc_no"] = event.item.parameter;
					} else {
						url = "/cust/cust0301p05";
						param["machine_deposit_result_seq"] = event.item.parameter;
					}
					$M.goNextPage(url, $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
		}
	</script>
</head>
<body>
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
			<div class="title-wrap">
				<h4>고객장비거래원장</h4>
			</div>
			<div class="row">
				<div class="col-6">
					<table class="table-border mt5">
						<colgroup>
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right">고객명</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0" readonly="readonly" id="cust_name" name="cust_name">
									<input type="hidden" class="form-control border-right-0" readonly="readonly" id="cust_no" name="cust_no">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('setCustInfo');"><i class="material-iconssearch"></i></button>
								</div>
							</td>
							<th class="text-right">업체명</th>
							<td>
								<input type="text" class="form-control" readonly="readonly" id="breg_name" name="breg_name">
							</td>
						</tr>
						<tr>
							<th class="text-right">대표자</th>
							<td>
								<input type="text" class="form-control width140px" readonly="readonly" id="breg_rep_name" name="breg_rep_name">
							</td>
							<th class="text-right">입금자</th>
							<td>
								<input type="text" class="form-control width140px" readonly="readonly" id="deposit_name" name="deposit_name">
							</td>
						</tr>
						<tr>
							<th class="text-right">전화</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" id="hp_no" name="hp_no" format="phone" maxlength="11">
							</td>
							<th class="text-right">팩스</th>
								<td>
									<input type="text" class="form-control width140px" readonly="readonly" id="fax_no" name="fax_no">
								</td>
							</tr>
							<tr>
								<th class="text-right">담당자</th>
								<td>
									<input type="text" class="form-control width140px" readonly="readonly" id="sale_mem_name" name="sale_mem_name">
									<input type="hidden" class="form-control width140px" readonly="readonly" id="sale_mem_no" name="sale_mem_no">
								</td>
								<th class="text-right">관리번호</th>
								<td>
									<input type="text" class="form-control width140px" readonly="readonly" id="" name="">
								</td>
							</tr>
							<tr>
								<th class="text-right">주소</th>
								<td colspan="3">
									<div class="form-row inline-pd mb7">
										<div class="col-3">
											<input type="text" class="form-control" readonly="readonly" id="post_no" name="post_no">
										</div>
										<div class="col-9">
											<input type="text" class="form-control" readonly="readonly" id="addr1" name="addr1">
										</div>
									</div>
									<div class="form-row inline-pd">
										<div class="col-12">
											<input type="text" class="form-control" readonly="readonly" id="addr2" name="addr2">
										</div>
									</div>
								</td>
							</tr>																				
						</tbody>
					</table>
				</div>
				<div class="col-6">
					<div id="auiGridTop" style="margin-top: 5px; height: 215px;"></div>
				</div>
			</div>
		</div>
		<!-- /폼테이블 -->
		<!-- 폼테이블2 -->
		<div>
			<div class="title-wrap mt10">
				<h4>상세내역</h4>
			</div>
			<div id="auiGridBottom" style="margin-top: 5px; height: 215px;"></div>
		</div>
		<!-- /폼테이블2 -->
		<div class="btn-group mt10">
			<div class="left">
				총 <strong class="text-primary" id="total_cnt">0</strong>건
			</div>
			<div class="right">
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
			</div>
		</div>
	</div>
</div>
<!-- /팝업 -->

</body>
</html>