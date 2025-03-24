<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 매출관리 > 세금계산서관리 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var centerList = ${orgCenterListJson};
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			fnInit();
			goSearch();
		});
		
		function fnInit() {
			var managementYn = "${managementYn}";
			$M.setValue("management_yn", managementYn);

			if(${checkYn} == "Y") {
				$M.reloadComboData("s_org_code", []);
			}
			
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "taxbill_no",
				// No. 제거
				showRowNumColumn: true,
				// 고정칼럼 카운트 지정
				// fixedColumnCount : 11,
				editable : false,
				headerHeight : 40,
				showFooter : true,
				footerPosition : "top",
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true
			};
			var columnLayout = [
				{
					headerText : "발행일자", 
					dataField : "taxbill_dt", 
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "65",
					minWidth : "65",
					style : "aui-center"
				},
				{ 
					headerText : "번호", 
					dataField : "taxbill_no", 
					width : "90",
					minWidth : "90",
					style : "aui-center aui-popup",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var taxbillNo = value;
						return taxbillNo.substring(4, 16);
					}
				},
				{ 
					headerText : "매출<br\>구분", 
					dataField : "taxbill_doc_type_name", 
					width : "60",
					minWidth : "60",
					style : "aui-center",
				},
				{
					dataField : "taxbill_doc_type_cd",
					visible : false
				},
				{ 
					headerText : "부서", 
					dataField : "org_name", 
					width : "45",
					minWidth : "45",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var orgName = value;
						// 2021-07-09 부서가 없을때 조회 로딩중 멈춤현상 수정 - 황빛찬
						if (orgName != undefined) {
							return orgName.replace("센터", "");
						}
					}
				},
				{
					dataField : "org_code",
					visible : false
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "120",
					minWidth : "120",
					style : "aui-center aui-popup",
				},
				{ 
					headerText : "업체명", 
					dataField : "breg_name", 
					width : "130",
					minWidth : "120",
					style : "aui-center"
				},
				{ 
					headerText : "사업자번호", 
					dataField : "breg_no", 
					width : "110",
					minWidth : "100",
					style : "aui-center"
				},
				{
					headerText : "대표자명",
					dataField : "breg_rep_name",
					width : "100",
					minWidth : "100",
					style : "aui-center"
				},
				{ 
					headerText : "물품대", 
					dataField : "taxbill_amt",
					width : "95",
					minWidth : "85",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{ 
					headerText : "VAT", 
					dataField : "vat_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "95",
					minWidth : "85",
					style : "aui-right"
				},
				{ 
					headerText : "합계", 
					dataField : "total_amt",
					dataType : "numeric",
					formatString : "#,##0",
					minWidth : "85",
					width : "95",
					style : "aui-right"
				},
				{
					headerText : "카드수금액",
					dataField : "card_amt",
					dataType : "numeric",
					formatString : "#,##0",
					minWidth : "85",
					width : "95",
					style : "aui-right"
				},
				{ 
					headerText : "적요", 
					dataField : "desc_text",
					width : "180",
					minWidth : "130",
					style : "aui-left"
				},
				{
					headerText : "영수<br\>구분",
					dataField : "taxbill_type_cd",
					width : "60",
					minWidth : "60",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var taxbillTypeName = "";
						console.log();
						if(value == "1") {
							taxbillTypeName = "영수";
						} else if (value == "2") {
							taxbillTypeName = "청구";
						} else if (value == "3") {
							taxbillTypeName = "카드발행";
						}
						return taxbillTypeName;
					}
				},
				{ 
					headerText : "자료<br\>구분", 
					dataField : "issu_yn",
					width : "60",
					minWidth : "60",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						
						var issuYn = "";
						if(value == "Y") {
							issuYn = "발행";
						} else if (value == "N") {
							issuYn = "가발행";
						} else if (value == "R") {
							issuYn = "수정";
						} else if (value == "U") {
							issuYn = "중고";
						} else if (value == "M") {
							issuYn = "렌탈장비";
						}
						return issuYn;
					}
				},
				{ 
					headerText : "처리결과", 
					dataField : "err_msg",
					width : "125",
					minWidth : "110",
					style : "aui-left"
				},
				/*{
					headerText : "E-Mail", 
					dataField : "email",
					width : "100",
					minWidth : "100",
					style : "aui-left aui-popup"
				},*/
				{ 
					headerText : "회계전송일", 
					dataField : "duzon_trans_date",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "65",
					minWidth : "65",
					style : "aui-center"
				},
				{ 
					headerText : "계산서<br\>신고일", 
					dataField : "issu_seqno",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "65",
					minWidth : "65",
					style : "aui-center"
				},
				{ 
					headerText : "처리<br\>구분", 
					dataField : "report_yn",
					width : "45",
					minWidth : "45",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value == "Y" ? "신고" : "";
					}
				},
				{ 
					headerText : "처리자", 
					dataField : "issu_mem_name",
					width : "50",
					minWidth : "45",
					style : "aui-center"
				},
				{
					dataField : "issu_mem_no",
					visible : false
				},
				{
					dataField : "issu_status_yn",
					visible : false
				},
				{
					dataField : "account_link_cd",
					visible : false
				},
				{
					dataField : "end_yn",
					visible : false
				},
				{
					dataField : "inout_doc_type_cd",
					visible : false
				},
				{
					dataField : "taxbill_send_cd",
					visible : false
				},
				{
					dataField : "cust_no",
					visible : false
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "breg_name",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "taxbill_amt",
					positionField : "taxbill_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "vat_amt",
					positionField : "vat_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "total_amt",
					positionField : "total_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "card_amt",
					positionField : "card_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "taxbill_no" ) {
					var params = {
							"taxbill_no" : event.item["taxbill_no"]
					};
					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=750, left=0, top=0";
					$M.goNextPage('/acnt/acnt0301p02', $M.toGetParam(params), {popupStatus : popupOption});
				}
				if(event.dataField == "email" ) {
					var param = {
							"to" : event.item["email"]
					};
					openSendEmailPanel($M.toGetParam(param));
				}

				if(event.dataField == "cust_name" ) {
					// 거래원장상세
					var params = {
						"s_cust_no" : event.item["cust_no"],
						"s_start_dt" : $M.getValue("s_start_dt"),
						"s_end_dt" : $M.getValue("s_end_dt"),
						"s_ledger_yn" : "Y"
					};
					openDealLedgerPanel($M.toGetParam(params));

				}
			});	
		}
		
		//조회
		function goSearch() { 
			$M.setValue("s_org_code_str", $M.getValue("s_org_code"));
			$M.setValue("s_taxbill_doc_type_cd_str", $M.getValue("s_taxbill_doc_type_cd"));
			$('#s_org_code').combogrid("setValues", "");
// 			$('#s_taxbill_doc_type_cd').combogrid("setValues", "");
			var param = {
					"s_sort_key" : "t.taxbill_dt desc, t.taxbill_no", 
					"s_sort_method" : "desc",
					"s_search_type" : "Y",
					"s_org_code_str" : $M.getValue("s_org_code_str"),
					"s_taxbill_doc_type_cd_str" : $M.getValue("s_taxbill_doc_type_cd_str"),
					"s_issu_yn" : $M.getValue("s_issu_yn"),
					"s_issu_status_yn" : $M.getValue("s_issu_status_yn"),
					"s_taxbill_stat_cd" : $M.getValue("s_taxbill_stat_cd"),
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_end_dt" : $M.getValue("s_end_dt")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
							$M.reloadComboData("s_org_code", result.orgList);
							
							var orgCodeArr = $M.getValue("s_org_code_str").split("#");
							
							var arrList = new Array();
							
							for(var i = 0; i < orgCodeArr.length; i++) {
								for(var j = 0; j < centerList.length; j++) {
									if(orgCodeArr[i] == centerList[j].org_code) {
										arrList.push(centerList[j].org_name);
									}
								}
							}
							$('#s_org_code').combogrid("setValues", orgCodeArr);  
							$('#s_org_code').combogrid("setText", arrList);  
						};
					}
				);
		} 
		
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
					// 제외항목
				    exceptColumnFields : ["taxbill_send_cd", "taxbill_doc_type_cd", "org_code", "issu_mem_no", "inout_doc_type_cd", "end_yn", "account_link_cd", "issu_status_yn"]
			  };
			  fnExportExcel(auiGrid, "세금계산서관리", exportProps);
		}
		
		
		// 자료송신처리
		function goTaxTrans() {
			// issu_status_yn가 'N'인 애만 국세청 신고 가능
			// 이미 송신한 세금계산서가 있습니다.
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);

			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}
			
			for (var i = 0; i < items.length; i++) {

				// 전송을 했었고 && (정상처리 이거나 아직 taxbill쪽에서 처리가 안됐으면)
				if(items[i].report_yn == "Y" && (items[i].err_cd == "000000" || items[i].err_cd == "")) {
					alert("이미 송신한 세금계산서가 있습니다.");
					return false;
				}

				// 전송을 했었고 && 정상처리가 돼었으면
				if(items[i].report_yn == "Y" && items[i].err_cd == "000000") {
					alert("이미 송신한 세금계산서가 있습니다.");
					return false;
				}

				if(items[i].taxbill_send_cd == "5") {
					alert("수정세금계산서 건은 송신할 수 없습니다.");
					return false;
				}
				if(items[i].duzon_trans_yn != "Y" && items[i].issu_yn != 'N') {
					alert("회계전송이 완료된 자료만 자료송신처리가 가능합니다.");
					return false;
				}
			}

			var param = {
					taxbill_no_str : $M.getArrStr(items, {key : 'taxbill_no'}),
			}
			
			var msg = "처리 후 수정 및 삭제가 불가합니다.\n자료송신처리를 하시곘습니까?";
			$M.goNextPageAjaxMsg(msg, this_page + "/taxTrans", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}
		
		// 회계전송
		function goAccTrans() {
			var row = "";
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			var gridData = AUIGrid.getGridData(auiGrid);
			
			console.log("items : ", items);
			
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}
			for (var i = 0; i < items.length; i++) {
				if($M.getValue("management_yn") != "Y" && items[i].inout_doc_type_cd != "22") {
					if(items[i].end_yn != "Y") {
						alert("마감처리된 건만 회계처리가 가능합니다.");
						return false;
					}
				}
				if(items[i].duzon_trans_date != "") {
					alert("회계처리된 데이터가 있습니다.");
					return false;
				}
				if(items[i].account_link_cd == "") {
					for(var j = 0; j < gridData.length; j++) {
						if(items[i].taxbill_no == gridData[j].taxbill_no) {
							row = j + 1;
						}
					}
					alert(row + "행의 회계거래처코드가 없습니다.");
					return false;
				}
			}

			var param = {
					taxbill_no_str : $M.getArrStr(items, {key : 'taxbill_no'}),
			}
			
			if (confirm("회계전송하시겠습니까?") == false) {
				return false;
			}
			
			$M.goNextPageAjax(this_page + "/accTrans", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}
		
		function goCancelAccTrans() {
			var row = "";
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}
			
			for (var i = 0; i < items.length; i++) {
				if(items[i].duzon_trans_date == "") {
					alert("회계처리된 건만 취소가 가능합니다.");
					return false;
				}
			}

			var param = {
					taxbill_no_str : $M.getArrStr(items, {key : 'taxbill_no'}),
			}
			
			var msg = "회계전송을 취소하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page + "/cancelAccTrans", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="management_yn" name="management_yn">
<input type="hidden" id="s_org_code_str" name="s_org_code_str">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">			
<!-- 검색영역 -->					
					<div class="search-wrap">				
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="260px">								
								<col width="40px">
								<col width="200px">
								<col width="60px">
								<col width="200px">
								<col width="55px">
								<col width="110px">
								<col width="55px">
								<col width="90px">
								<col width="55px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>발행기간</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_end_dt}">
												</div>
											</div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="goSearch();"/>
				                     		</jsp:include>	
										</div>							
									</td>
									<th>부서</th>
									<td>
										<input class="form-control" style="width: 99%;" type="text" id="s_org_code" name="s_org_code" easyui="combogrid"
											   easyuiname="orgList" panelwidth="200" idfield="org_code" textfield="org_name" multi="Y"/>								
									</td>
									<th>매출구분</th>
									<td> <!-- 21.04.06 관리부 요청으로 매출구분 중복으로 선택할 수 있게 변경 -->
										<input class="form-control" style="width: 99%;" type="text" id="s_taxbill_doc_type_cd" name="s_taxbill_doc_type_cd" easyui="combogrid"
											   easyuiname="taxList" panelwidth="200" idfield="code_value" textfield="code_name" multi="Y"/>	
									</td>
									<th>자료구분</th>
									<td>
										<select class="form-control" id="s_issu_yn" name="s_issu_yn">
											<option value="">- 전체 -</option>
											<option value="Y">발행</option>
											<option value="N">가발행</option>
											<option value="R">수정세금계산서</option>
											<option value="U">중고</option>
											<option value="M">렌탈장비</option>
										</select>
									</td>
									<th>처리구분</th>
									<td>
										<select class="form-control" id="s_issu_status_yn" name="s_issu_status_yn">
											<option value="N">미처리건</option>
											<option value="Y">신고완료</option>
										</select>
									</td>
									<th>응답상태</th>
									<td>
										<select class="form-control" id="s_taxbill_stat_cd" name="s_taxbill_stat_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['TAXBILL_STAT']}" var="item">
											<option value="${item.code_value}"> <c:if test="${item.use_yn eq 'Y'}">${item.code_name}</c:if></option>
											</c:forEach>
										</select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>									
								</tr>						
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->
<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>		
					</div>				
				</div>
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>