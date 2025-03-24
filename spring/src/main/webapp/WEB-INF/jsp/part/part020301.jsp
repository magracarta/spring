<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품발송-출고처리 > 부품출고처리 > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-14 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;
	
	$(document).ready(function() {
		createAUIGrid();
		fnInit();
	});
	
	function fnInit() {
		var org = ${orgBeanJson};
		if(org.org_gubun_cd != "BASE") {
			$("#s_org_code").prop("disabled", true);
		}
	}

	function goSearch() {
		var frm = document.main_form;
		//validationcheck
		if ($M.validation(frm,
				{field: ["s_start_dt", "s_end_dt"]}) == false) {
			return;
		}

		if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
			return;
		};

		var param = {
			"s_start_dt": $M.getValue("s_start_dt"),
			"s_end_dt": $M.getValue("s_end_dt"),
			"s_org_code": $M.getValue("s_org_code"),
			"s_invoice_send_cd": $M.getValue("s_invoice_send_cd"),
			"s_invoice_send_status_cd": $M.getValue("s_invoice_send_status_cd"),
		};
		_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
				function (result) {
					if (result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					}
				}
		);
	}

	function fnDownloadExcel() {
		fnExportExcel(auiGrid, "부품출고처리");
	}

	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColum : true,
			// 고정칼럼 카운트 지정
			// fixedColumnCount : 4
		};
		
		var columnLayout = [
			{
				headerText : "전표번호",
				dataField : "doc_no",
				width : "90",
				minWidth : "90",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					var docNo = value;
					return docNo.substring(4, 16);
				},
				style : "aui-center aui-popup"
			},
			{
				headerText : "성명",
				dataField : "receive_send_name",
				width : "120",
				minWidth : "120",
				style : "aui-center"
			},
			{
				headerText : "전화번호",
				dataField : "send_tel_no",
				width : "110",
				minWidth : "110",
				style : "aui-center"
			},
			{
				headerText : "고객휴대폰",
				dataField : "receive_hp_no",
				width : "110",
				minWidth : "110",
				style : "aui-center"
			},
			{
				headerText : "발송지",
				dataField : "send_addr",
				width : "250",
				minWidth : "250",
				style : "aui-left"
			},
			{
				headerText : "송장번호",
				dataField : "invoice_no",
				width : "110",
				minWidth : "110",
				style : "aui-center"
			},
			{
				headerText : "비고",
				dataField : "remark",
				width : "150",
				minWidth : "150",
				style : "aui-left"
			},
			{
				headerText : "발송센터",
				dataField : "send_out_dept_name",
				width : "70",
				minWidth : "70",
				style : "aui-center"
			},
			{
				headerText : "발송구분",
				dataField : "invoice_send_name",
				width : "70",
				minWidth : "70",
				style : "aui-center aui-popup"
			},
			{
				headerText : "발송상태",
				dataField : "invoice_send_status_name",
				width : "65",
				minWidth : "65",
				style : "aui-center"
			},
			{
				headerText : "배송구분",
				dataField : "invoice_money_name",
				width : "65",
				minWidth : "65",
				style : "aui-center"
			},
			{
				headerText : "배송비",
				dataField : "delivery_fee",
				width : "70",
				minWidth : "70",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0"
			},
			{
				headerText : "발송처리자",
				dataField : "send_name",
				width : "90",
				minWidth : "90",
				style : "aui-center"
			},
			{
				headerText : "처리자",
				dataField : "reg_mem_name",
				width : "80",
				minWidth : "80",
				style : "aui-center"
			},
			{
				headerText : "고객명",
				dataField : "receive_name",
				width : "100",
				minWidth : "100",
				style : "aui-center"
			},
			{
				headerText : "휴대폰",
				dataField : "send_hp_no",
				width : "110",
				minWidth : "110",
				style : "aui-center"
			},
			{
				headerText : "전표비고",
				dataField : "view_remark",
				width : "180",
				minWidth : "180",
				style : "aui-left"
			},
			{
				headerText : "전표마감",
				dataField : "day_end",
				width : "60",
				minWidth : "60",
				style : "aui-center"
			},
			{
				headerText : "전표바코드",
				dataField : "doc_barcode_no",
				visible : false
			},
			{
				headerText : "송장타입코드",
				dataField : "invoice_type_cd",
				visible : false
			},
			{
				headerText : "품의서구분코드",
				dataField : "inout_doc_type_cd",
				visible : false
			},
			{
				headerText : "고객번호",
				dataField : "receive_cust_no",
				visible : false
			},
			{
				headerText : "송장발송번호",
				dataField : "send_invoice_seq",
				visible : false
			},
			{
				headerText : "발송센터코드",
				dataField : "send_out_dept_code",
				visible : false
			},
			{
				headerText : "고객앱여부",
				dataField : "cust_app_yn",
				visible : false
			},
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		$("#auiGrid").resize();

		AUIGrid.bind(auiGrid, "cellClick", function(event){
			if(event.dataField == "doc_no") {
				var params = {
					"doc_barcode_no" : event.item.doc_barcode_no,
					"send_out_dept_code" : event.item.send_out_dept_code,
					"send_invoice_seq" : event.item.send_invoice_seq
				};

				var popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=480, left=0, top=0";
				$M.goNextPage('/part/part0203p01', $M.toGetParam(params), {popupStatus : popupOption});
			}

			if(event.dataField == "invoice_send_name") {
				goSearchSendInvoice(event.item);
			}
		});
	}

	function goSearchSendInvoice(item) {
		var sendInvoiceSeq = item.send_invoice_seq;
		var params = {
			"s_send_invoice_seq" : sendInvoiceSeq
		}

		$M.goNextPageAjax(this_page + "/invoice/search", $M.toGetParam(params), {method : 'GET'},
				function(result) {
					if(result.success) {
						result.bean.app_yn = item.cust_app_yn;
						result.bean.invoice_desc_text = item.send_addr;
						goDeliveryInfo(result.bean);
					}
				}
		);
	}

	function goDeliveryInfo(bean) {
		var invoiceNo = typeof bean.invoice_no == "undefined" ? "" : bean.invoice_no;
		var remark = typeof bean.remark == "undefined" ? "" : bean.remark;
		var receiveTelNo = typeof bean.receive_tel_no == "undefined" ? "" : bean.receive_tel_no;
		var postNo = typeof bean.post_no == "undefined" ? "" : bean.post_no;
		var addr1 = typeof bean.addr1 == "undefined" ? "" : bean.addr1;
		var addr2 = typeof bean.addr2 == "undefined" ? "" : bean.addr2;

		var params = {
			"cust_no" : bean.cust_no,
			"invoice_type_cd" : bean.invoice_type_cd,
			"invoice_money_cd" : bean.invoice_money_cd,
			"invoice_send_cd" : bean.invoice_send_cd,
			"receive_name" : bean.receive_name,
			"invoice_no" : invoiceNo,
			"receive_hp_no" : $M.phoneFormat(bean.receive_hp_no),
			"receive_tel_no" : receiveTelNo,
			"qty" : bean.qty,
			"remark" : remark,
			"post_no" : postNo,
			"addr1" : addr1,
			"addr2" : addr2,
			"print_yn" : "Y",
			"app_yn" : bean.app_yn,
			"invoice_desc_text" : bean.invoice_desc_text
		};

		openDeliveryInfoPanel('setDeliveryInfo', $M.toGetParam(params));
	}

	function setDeliveryInfo() {
	}
	
	function fnGetPageData() {
		// 그리드에 체크된 값 가져오기
		var rows = AUIGrid.getGridData(auiGrid);
		
		for(var i = 0 ; i < rows.length ; i++){
			rows[i].start_dt = $M.getValue("s_start_dt");
			rows[i].end_dt = $M.getValue("s_end_dt");
		}		
		
		return rows;
	}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<div class="layout-box">

<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- /메인 타이틀 -->
				<div class="contents">
<!-- 검색영역 -->		
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="260px">
								<col width="40px">
								<col width="100px">
								<col width="80px">
								<col width="100px">
								<col width="80px">
								<col width="100px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>								
									<th>발송일자</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">
												~
											</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${searchDtMap.s_end_dt}">
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
									<th>센터</th>
									<td>
										<select class="form-control" id="s_org_code" name="s_org_code">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['WAREHOUSE']}">
												<option value="${item.code_value}" <c:if test="${item.code_value == orgBean.org_code}">selected="selected"</c:if> >${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>발송구분</th>
									<td>
										<select class="form-control" id="s_invoice_send_cd" name="s_invoice_send_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['INVOICE_SEND']}">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>발송상태</th>
									<td>
										<select class="form-control" id="s_invoice_send_status_cd" name="s_invoice_send_status_cd">
											<option value="">- 전체- </option>
											<option value="N">미발송</option>
											<option value="Y">발송</option>
										</select>
									</td>							
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /검색영역 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px; height: 555px; width: 100%;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong id="total_cnt" class="text-primary">0</strong>건
						</div>						
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
						
			</div>		
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>