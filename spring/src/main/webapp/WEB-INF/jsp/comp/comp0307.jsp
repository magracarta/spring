<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 고객연관팝업 > 고객연관팝업 > null > 고객조회
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
</head>
<script type="text/javascript">

	var auiGrid;
	
	$(document).ready(function() {
		createAUIGrid();
		var custName = "${inputParam.s_cust_name}";
		
		if (custName != "") {
			$M.setValue("s_cust_name", custName);
			goSearch();
		}
	});

	//조회
	function goSearch() { 
		var param = {
				"s_sort_key" : "saledoc.cust_name asc, saledoc.hp_no asc, saledoc.machine_doc_no",
				"s_sort_method" : "asc",
				"s_cust_name" : $M.getValue("s_cust_name"),
				"s_breg_name" : $M.getValue("s_breg_name"),
				"s_breg_no" : $M.getValue("s_breg_no"),
				"s_addr" : $M.getValue("s_addr"),
				"s_hp_no" : $M.getValue("s_hp_no"),
				"s_tel_no" : $M.getValue("s_tel_no"),
				"s_machine_plant_seq" : $M.getValue("s_machine_plant_seq"),
				"s_write_yn" : $M.getValue("s_write_yn"),
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				"s_agency_yn" : "${inputParam.s_agency_yn}" == "Y" ? "Y" : "N"
		};
		$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGrid, result.list);
					$("#total_cnt").html(result.total_cnt);
				};
			}
		);
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_cust_name", "s_breg_name", "s_breg_no", "s_addr", "s_hp_no", "s_tel_no"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch(document.main_form);
			};
		});
	}
	
	function createAUIGrid() {
		var gridPros = {
			// rowIdField 설정
			rowIdField : "cust_no",
			// rowNumber 
			showRowNumColumn: true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
		};
		var columnLayout = [
			{
				headerText : "품의번호", 
				dataField : "machine_doc_no", 
				width : "10%", 
				style : "aui-center",
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					return value = value.substring(0, 11);
				}
			},
			{ 
				headerText : "차주명", 
				dataField : "cust_name", 
				width : "14%", 
				style : "aui-center"
			},
			{
				dataField : "real_cust_name",
				visible : false
			},
			{
				dataField : "real_hp_no",
				visible : false
			},
			{ 
				headerText : "휴대폰", 
				dataField : "hp_no", 
				width : "12%", 
				style : "aui-center",
			},
			{ 
				headerText : "판매점", 
				dataField : "doc_org_name", 
				width : "10%", 
				style : "aui-center",
			},
			{ 
				headerText : "판매자", 
				dataField : "doc_mem_name", 
				width : "8%", 
				style : "aui-center"
			},
			{ 
				headerText : "상품명", 
				dataField : "machine_name", 
				style : "aui-left"
			},
			{ 
				headerText : "출하일자", 
				dataField : "out_dt",
				dataType : "date",  
				formatString : "yyyy-mm-dd",
				width : "9%",  
				style : "aui-center"
			},
			{ 
				headerText : "매출금", 
				dataField : "total_vat_amt", 
				dataType : "numeric",
				formatString : "#,##0",
				width : "9%", 
				style : "aui-right"
			},
			{
				headerText : "입금액",
				dataField : "deposit_amt", 
				dataType : "numeric",
				formatString : "#,##0",
				width : "9%", 
				style : "aui-right"
			},
 			{ 
				headerText : "미결재금", 
				dataField : "misu_amt", 
				dataType : "numeric",
				formatString : "#,##0",
				width : "9%", 
				style : "aui-right"
			},
			{
				dataField : "doc_mem_no",
				visible : false
			},
			{
				dataField : "doc_org_code",
				visible : false
			},
			{
				dataField : "addr1",
				visible : false
			},
			{
				dataField : "addr2",
				visible : false
			},
			{
				dataField : "cust_no",
				visible : false
			}
		]
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, []);
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			// Row행 클릭 시 반영
			try{
				opener.${inputParam.parent_js_name}(event.item);
				window.close();	
			} catch(e) {
				alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
			}
		});	
		$("#auiGrid").resize();
	}
	
	//모델조회
	function setModelInfo(row) {
		$M.setValue("s_machine_name", row.machine_name);
	}
	
	//팝업 끄기
	function fnClose() {
		window.close(); 
	}

</script>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 팝업 (문자발송) -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	  
<!-- 검색조건 -->
			<div class="search-wrap">
				<table class="table">
					<colgroup>
						<col width="40px">
						<col width="50px">
						<col width="40px">
						<col width="50px">
						<col width="40px">
						<col width="60px">
						<col width="30px">
						<col width="80px">
						<col width="1px">
					</colgroup>
					<tbody>
						<tr>
							<th>차주명</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_cust_name" name="s_cust_name" class="form-control" placeholder="">
								</div>
							</td>
							<th>업체명</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_breg_name" name="s_breg_name" class="form-control">
								</div>
							</td>
							<th>사업자번호</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_breg_no" name="s_breg_no" class="form-control" placeholder="-없이 숫자만" datatype="int">
								</div>
							</td>
							
							<th>주소</th>
							<td >
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_addr" name="s_addr" class="form-control">
								</div>
							</td>
						</tr>
						<tr>
							<th>휴대폰</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_hp_no" name="s_hp_no" class="form-control" placeholder="-없이 숫자만" datatype="int">
								</div>
							</td>
							<th>전화</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" id="s_tel_no" name="s_tel_no" class="form-control" placeholder="-없이 숫자만" datatype="int">
								</div>
							</td>
							<th>모델</th>
							<td>
								<div class="form-row">
									<div class="col-12">
										<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
				                     		<jsp:param name="required_field" value=""/>
				                     		<jsp:param name="s_maker_cd" value=""/>
				                     		<jsp:param name="s_machine_type_cd" value=""/>
				                     		<jsp:param name="s_sale_yn" value=""/>
				                     		<jsp:param name="readonly_field" value=""/>
				                     		<jsp:param name="execFuncName" value=""/>
				                     		<jsp:param name="focusInFuncName" value=""/>
				                     	</jsp:include>
									</div>
								</div>			
							</td>
							<th class="text-right" colspan="2">		
								<div class="form-check form-check-inline">
									<label class="form-check-label mr5" for="s_write_yn">작성중인 품의서 포함</label>
									<input class="form-check-input" type="checkbox" id="s_write_yn" name="s_write_yn" value="Y">
								</div>
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<div class="form-check form-check-inline">
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
								</div>
								</c:if>										
							</th>
							<td class="text-left"><button type="button" class="btn btn-important" style="width: 60px;" onclick="javascript:goSearch();">조회</button></td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /검색조건 -->
<!-- 검색결과 -->
			
			<div id="auiGrid" style="margin-top: 5px; height: 600px;"></div>
			
			<div class="btn-group mt5">	
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /검색결과 -->
        </div>
    </div>
    </form>
<!-- /팝업 (문자발송) -->
	
</body>
</html>