<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 장비입금관리-개별 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGridTop();
			createAUIGridBottom();
		});
		
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
					editable : false,
				};
			var columnLayout = [
				{
					headerText : "품의번호", 
					dataField : "machine_doc_no", 
					style : "aui-center aui-popup",
					width : "100",
					minWidth : "100",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
	                  var ret = "";
	                  if (value != null && value != "") {
	                     ret = value.split("-");
	                     ret = ret[0]+"-"+ret[1];
	                     ret = ret.substr(4, ret.length);
	                  }
	                   return ret; 
	               }, 
				},
				{ 
					headerText : "예정일", 
					dataField : "plan_dt", 
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "90",
					minWidth : "90",
					style : "aui-center"
				},
				{ 
					headerText : "구분", 
					dataField : "machine_pay_type_name", 
					width : "90",
					minWidth : "90",
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
					width : "120",
					minWidth : "120",
					style : "aui-right",
				},
				{ 
					headerText : "입금액", 
					dataField : "deposit_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "120",
					minWidth : "120",
					style : "aui-right",
				},
				{ 
					headerText : "잔액", 
					dataField : "balance_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "120",
					minWidth : "120",
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
				if(event.dataField == "machine_doc_no") {
					var params = {
						"machine_doc_no" : event.item["machine_doc_no"]	
					};
					var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=780, left=0, top=0";
					$M.goNextPage('/cust/cust0301p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
		}
		//그리드생성
		function createAUIGridBottom() {
			var gridPros = {
				// Row번호 표시 여부
				showRowNumColumn : true,
				showStateColumn : false,
				showBranchOnGrouping : false,
				showFooter : true,
				footerPosition : "top",
				editable : false,
			};
	
			var columnLayout = [
				{
					headerText : "품의번호",
					dataField : "machine_doc_no",
					width : "90",
					minWidth : "90",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
	                  var ret = "";
	                  if (value != null && value != "") {
	                     ret = value.split("-");
	                     ret = ret[0]+"-"+ret[1];
	                     ret = ret.substr(4, ret.length);
	                  }
	                   return ret; 
	               }, 
				},
				{
					headerText : "처리일자",
					dataField : "proc_dt",
					dataType : "date",
					width : "90",
					minWidth : "90",
					formatString : "yy-mm-dd",
				},
				{
					headerText : "내역",
					dataField : "proc_remark",
					width : "470",
					minWidth : "200",
					style : "aui-left aui-popup"
				},
				{
					headerText : "매출",
					dataField : "sale_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "140",
					minWidth : "140",
					style : "aui-right"
				},
				{
					headerText : "입금",
					dataField : "deposit_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "140",
					minWidth : "140",
					style : "aui-right"
				},
				{
					headerText : "잔액",
					dataField : "balance_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "140",
					minWidth : "140",
					style : "aui-right"
				},
				{
					headerText : "비고",
					dataField : "vat_dt",
					dataType : "date",
					width : "200",
					minWidth : "100",
					style : "aui-left",
					formatString : "yy-mm-dd"
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
	
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "machine_doc_no",
					style : "aui-center aui-footer",
					colSpan : 3
				}, 
				{
					dataField : "sale_amt",
					positionField : "sale_amt",
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
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
			// 그리드 갱신
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGridBottom, footerColumnLayout);
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
		
		 
		function goCustInfoClick() {
			var param = {
					s_cust_name : $M.getValue("cust_name"),
					s_agency_yn : ${page.fnc.F01022_001 eq 'Y'} ? "Y" : "N"
			};
			openMachineCustPanel('fnSetCustInfo', $M.toGetParam(param));
		}
		
		function goCustInfo() {
			if($M.validation(null, {field:['cust_name']}) == false) { 
				return;
			}
			var param = {
					s_cust_name : $M.getValue("cust_name"),
					s_agency_yn : ${page.fnc.F01022_001 eq 'Y'} ? "Y" : "N"
			};
			var url = "/comp/comp0307";
			$M.goNextPageAjax(url + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#cust_name").blur();
						var list = result.list;
						switch(list.length) {
							case 0 :
								$M.clearValue({field:["cust_name"]});
								break;
							case 1 : 
								var row = list[0];
								fnSetCustInfo(row)
								break;
							default :
								openMachineCustPanel('fnSetCustInfo', $M.toGetParam(param));
							break;
						}
					}
				}
			);
		}
		
		function fnSetCustInfo(row) {
			
			var param = {
					"machine_doc_no" : row.machine_doc_no
			}
			
			$M.goNextPageAjax(this_page + '/custInfo/' + row.cust_no, $M.toGetParam(param), {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			$M.setValue(result.custInfo);
		    			
		    			var cust = result.custInfo;
		    			
		    			$M.setValue("fax_no", $M.phoneFormat(cust.fax_no));
		    			$M.setValue("hp_no", $M.phoneFormat(cust.hp_no));
		    			
		    			AUIGrid.setGridData(auiGridTop, result.depositPlanList);
		    			
		    			var detailList = result.detailList;
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
	    
		// 엔터키 이벤트
		function enter(fieldObj) {
			var name = fieldObj.name;
			if (name == "cust_name") {
				goCustInfo();
			}
		} 
		
		 // 문자발송
		function fnSendSms() {
			var param = {
					  name : $M.getValue("cust_name"),
					  hp_no : $M.getValue("hp_no")
			  }
			openSendSmsPanel($M.toGetParam(param));
		}
		
	    function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {};
			  fnExportExcel(auiGridBottom, "장비입금관리-개별", exportProps);
		}
	    
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="cust_no" name="cust_no">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
					<div class="row">
						<div class="col-6">
<!-- 폼테이블 -->							
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
											<div class="input-group width140px">
												<input type="text" class="form-control border-right-0" id="cust_name" name="cust_name">
												<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goCustInfoClick();"><i class="material-iconssearch"></i></button>
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
											<div class="input-group width140px">
												<input type="text" class="form-control border-right-0" readonly="readonly" id="hp_no" name="hp_no">
												<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>
											</div>
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
										</td>
										<th class="text-right">관리번호</th>
										<td>
											<input type="text" class="form-control" readonly="readonly" id="" name="">
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
<!-- /폼테이블 -->								
						</div>
						<div class="col-6">
							<div id="auiGridTop" style="margin-top: 5px; height: 220px;"></div>
						</div>
					</div>
<!-- 처리내역 -->
					<div class="title-wrap mt10">
						<h4>처리내역</h4>
							<div>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
					</div>
					<div id="auiGridBottom" style="margin-top: 5px; height: 390px;"></div>
<!-- /처리내역 -->					
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>		
					</div>				
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>