<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 정비지시서 부품출고(반품)처리
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-09 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGrid;
	
	$(document).ready(function() {
		fnInit();

		// AUIGrid 생성
		createAUIGrid();
	});

	// 접수일자 Setting
	function fnInit() {
		var now = "${inputParam.s_current_dt}";
		$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
	}

	// 조회
	function goSearch() {
		var frm = document.main_form;
		if($M.validation(frm,
				{field:["s_start_dt", "s_end_dt"]}) == false) {
			return;
		};

		var params = {
			"s_start_dt" : $M.getValue("s_start_dt"),
			"s_end_dt" : $M.getValue("s_end_dt"),
			"s_org_code" : $M.getValue("s_org_code"),
			"s_job_status_cd" : $M.getValue("s_job_status_cd")
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method : "GET"},
			function (result) {
				if(result.success) {
					AUIGrid.setGridData(auiGrid, result.list);
					$("#total_cnt").html(result.total_cnt);
				}
			}
		);
	}

	// 닫기
	function fnClose() {
		window.close();
	}

	// 미처리 정비지시서 팝업
	function goList() {
		var params = {
			"s_org_code" : $M.getValue("s_org_code")
		};

		var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=440, left=0, top=0";
		$M.goNextPage('/serv/serv0101p10', $M.toGetParam(params), {popupStatus : popupOption});
	}
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
		};
		var columnLayout = [
			{ 
				headerText : "상담일자", 
				dataField : "consult_dt",
				style : "aui-center",
				dataType : "date",  
				formatString : "yyyy-mm-dd"
			},
			{
				headerText : "방문일자", 
				dataField : "visit_dt",
				style : "aui-center",
				dataType : "date",  
				formatString : "yyyy-mm-dd"
			},
			{ 
				headerText : "차주명", 
				dataField : "cust_name",
				style : "aui-center"
			},
			{ 
				headerText : "장비명", 
				dataField : "machine_name",
				style : "aui-center"
			},
			{ 
				headerText : "차대번호", 
				dataField : "body_no",
				style : "aui-center"
			},
			{ 
				headerText : "접수자", 
				dataField : "reg_mem_name",
				style : "aui-center"
			},
			{ 
				headerText : "정비자", 
				dataField : "assign_mem_name",
				style : "aui-center",
			},
			{ 
				headerText : "진행", 
				dataField : "job_status_name",
				style : "aui-center"
			},
			{ 
				headerText : "서비스일자", 
				dataField : "as_dt",
				style : "aui-center",
				dataType : "date",
				formatString : "yyyy-mm-dd"
			},
			{ 
				headerText : "관리번호",
				dataField : "job_report_no",
				width : "10%",
				style : "aui-center aui-popup"
			},
			{ 
				headerText : "작업사업장", 
				dataField : "org_name",
				style : "aui-center"
			},
			{ 
				headerText : "접수", 
				dataField : "qty",
				width : "5%",
				style : "aui-center"
			},
			{ 
				headerText : "출고", 
				dataField : "out_qty",
				width : "5%",
				style : "aui-center"
			},
			{ 
				headerText : "사용", 
				dataField : "use_qty",
				width : "5%",
				style : "aui-center"
			},
			{ 
				headerText : "반품", 
				dataField : "in_qty",
				width : "5%",
				style : "aui-center"
			},
			{
				headerText : "바코드",
				dataField : "doc_barcode_no",
				visible : false
			},
			{
				headerText : "진행코드",
				dataField : "job_status_cd",
				visible : false
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "job_report_no" ) {
				if(event.item.job_status_cd == "0") {
					alert("[접수] 상태의 정비건은 출고처리 할 수 없습니다.");
					return;
				}

				var params = {
					"doc_barcode_no" : event.item.doc_barcode_no
				};

				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
				$M.goNextPage('/part/part0203p02', $M.toGetParam(params), {popupStatus : popupOption});
			}
		});	
		
		$("#auiGrid").resize();
	}	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
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
<!-- 검색영역 -->					
				<div class="search-wrap mt5">
					<table class="table">
						<colgroup>
							<col width="65px">
							<col width="270px">
							<col width="65px">
							<col width="100px">
							<col width="55px">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>접수일자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" required="required" value="${inputParam.s_current_dt}">
											</div>
										</div>
									</div>
								</td>
								<th>작업센터</th>
								<td>
									<select class="form-control" name="s_org_code" id="s_org_code" disabled="disabled">
										<option value="">- 전체 -</option>
										<c:forEach var="list" items="${codeMap['WAREHOUSE']}">
											<option value="${list.code_value}" <c:if test="${list.code_value eq inputParam.login_org_code}">selected</c:if> >${list.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>상태</th>
								<td>
									<select class="form-control" name="s_job_status_cd" id="s_job_status_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="list" items="${codeMap['JOB_STATUS']}">
											<option value="${list.code_value}">${list.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button></td>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /검색영역 -->
<!-- 조회결과 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
<!-- /조회결과 -->
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong id="total_cnt" class="text-primary">0</strong>건
				</div>	
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