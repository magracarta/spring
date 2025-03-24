<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 징계관리 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-04-29 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var auiGrid;
	
	$(document).ready(function() {
		// 그리드 생성
		createAUIGrid();
		goSearch();
	});
	
	// 그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : true,
			enableFilter :true,
			editable : false
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				dataField : "mem_no",
				visible : false
			},
			{
				headerText: "부서",
				dataField: "org_name",
				width : "90",
				style : "aui-center",
			},
			{
				headerText: "직원명",
				dataField: "mem_name",
				width : "100",
				style : "aui-center aui-popup",
			},
			{
				headerText: "직책",
				dataField: "grade_name",
				width : "70",
				style : "aui-center",
			},
			{
				headerText: "직급",
				dataField: "job_name",
				width : "70",
				style : "aui-center",
			},
			{
				headerText: "계정아이디",
				dataField: "web_id",
				width : "100",
				style : "aui-center",
			},
			{
				headerText: "사번",
				dataField: "emp_id",
				width : "80",
				style : "aui-center",
			},
			{
				headerText: "징계구분",
				dataField: "mem_penalty_name",
				width : "80",
				style : "aui-center",
			},
			{
				headerText: "등급",
				dataField: "penalty_grade_name",
				width : "50",
				style : "aui-center",
			},
			{
				headerText: "반영일자",
				dataField: "apply_dt",
				width : "80",
				dataType : "date",  
				formatString : "yy-mm-dd",
				style : "aui-center",
			},
			{
				headerText: "사유서",
				dataField: "file_yn",
				width : "60",
				style : "aui-center",
			},
			{
				headerText: "비고",
				dataField: "remark",
				width : "250",
				style : "aui-left",
			},
			{
				headerText: "결재",
				dataField: "path_appr_job_status_name",
				width : "250",
				style : "aui-left",
			},
			{
				dataField : "doc_no",
				visible : false
			}
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, []);
		$("#auiGrid").resize();
		
		// 직원조회 팝업 호출
		AUIGrid.bind(auiGrid, "cellClick", function(event){
			if(event.dataField == "mem_name") {
				var param = {
					mem_penalty_no : event.item.mem_penalty_no
				};
					
				var popupOption = "";
				$M.goNextPage('/acnt/acnt0604p01', $M.toGetParam(param), {popupStatus : popupOption});
			}
		});
	}
	
	function goSearch() {
		var param = {
				"s_work_status_yn" : $M.getValue("s_work_status_yn"),  // 퇴사자제외
				"s_start_year" : $M.getValue("s_start_year") + "0101",
				"s_end_year" : $M.getValue("s_end_year") + "1231",
				"s_mem_name" : $M.getValue("s_mem_name"),
				"s_mem_penalty_cd" : $M.getValue("s_mem_penalty_cd"),
				"s_org_code" : $M.getValue("s_org_code")
		};
		
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);
				};
			}		
		);	
	}
	
	// 엑셀 다운로드
	function fnExcelDownload() {
	  // 엑셀 내보내기 속성
	  var exportProps = {};
	  fnExportExcel(auiGrid, "징계관리", exportProps);
	}
	
	// 징계등록
	function goNew() {
		$M.goNextPage("/acnt/acnt060401");
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_mem_name"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
	}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
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
                                <col width="65px">
                                <col width="180px">
                                <col width="40px">
                                <col width="100px">
                                <col width="60px">
                                <col width="100px">
                                <col width="65px">
                                <col width="100px">
                                <col width="110px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                                <tr>							
                                    <th>조회년도</th>	
                                    <td>
	                                    <div class="form-row inline-pd">
	                                        <div class="col-auto">
												<select class="form-control" id="s_start_year" name="s_start_year">
													<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
														<option value="${i}" <c:if test="${i==inputParam.s_current_year-1}">selected</c:if>>${i}년</option>
													</c:forEach>
												</select>
	                                        </div>
	                                        <div class="col-auto text-center">~</div>
	                                        <div class="col-auto">
												<select class="form-control" id="s_end_year" name="s_end_year">
													<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
														<option value="${i}" <c:if test="${i==inputParam.s_current_year}">selected</c:if>>${i}년</option>
													</c:forEach>
												</select>
	                                        </div>
	                                    </div>
                                    </td>
                                    <th>부서</th>
                                    <td>
										<select class="form-control" id="s_org_code" name="s_org_code">
											<option value="">- 선택 -</option>
											<c:forEach items="${orgList}" var="item">
												<option value="${item.org_code}">${item.org_name}</option>
											</c:forEach>
										</select>
                                    </td>		
                                    <th>직원명</th>
                                    <td>    
                                        <input type="text" class="form-control" id="s_mem_name" name="s_mem_name">
                                    </td>		
                                    <th>징계구분</th>
                                    <td>    
										<select class="form-control" id="s_mem_penalty_cd" name="s_mem_penalty_cd">
											<option value="">- 선택 -</option>
											<c:forEach items="${codeMap['MEM_PENALTY']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
                                    </td>		
                                    <td class="pl15">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_work_status_yn" name="s_work_status_yn" value="Y" checked="checked">
											<label class="form-check-label" for="s_work_status_yn">퇴사자제외</label>
										</div>
                                    </td>						
                                    <td class="">
                                        <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
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
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
                        </div>		
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                        </div>
					</div>				
				</div>
			</div>		
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>