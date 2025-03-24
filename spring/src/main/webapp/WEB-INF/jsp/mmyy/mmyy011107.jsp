<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 기안문서 > 경력증명서 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-05-10 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;
	
	$(document).ready(function() {
		// 그리드 생성
		if ("${inputParam.init_yn}" == "Y") {
			createAUIGrid();
			goSearch();
		}
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
				dataField : "doc_no",
				visible : false
			},
			{
				headerText: "작성일자",
				dataField: "doc_dt",
				width : "70",
				style : "aui-center",
				dataType : "date",  
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
				editable : false,
			},
			{
				headerText: "부서",
				dataField: "org_name",
				width : "80",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "신청자",
				dataField: "apply_mem_name",
				width : "70",
				style : "aui-center aui-popup",
				editable : false,
			},
			{
				headerText: "작성자",
				dataField: "mem_name",
				width : "70",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "사번",
				dataField: "emp_id",
				width : "80",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "연락처",
				dataField: "hp_no",
				width : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "입사일",
				dataField: "ipsa_dt",
				width : "70",
				dataType : "date",  
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "퇴사일",
				dataField: "ipsa_dt",
				width : "70",
				dataType : "date",  
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "직무",
				dataField: "jjob_text",
				width : "80",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "회사의견",
				dataField: "cmp_text",
				width : "190",
				style : "aui-left",
				editable : false,
			},
			{
				headerText: "신청매수",
				dataField: "apply_cnt",
				width : "60",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "결재",
				dataField: "path_appr_job_status_name",
				width : "300",
				style : "aui-left",
				editable : false,
			},
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, []);
		$("#auiGrid").resize();
		
		// 직원조회 팝업 호출
		AUIGrid.bind(auiGrid, "cellClick", function(event){
			if(event.dataField == "apply_mem_name") {
				var param = {
					doc_no : event.item.doc_no
				};
					
				var popupOption = "";
				$M.goNextPage('/mmyy/mmyy011107p01', $M.toGetParam(param), {popupStatus : popupOption});
			}
		});
	}
	
	// 재직증명서 신청
	function goNew() {
		$M.goNextPage("/mmyy/mmyy01110701");
	}
	
	// 조회
	function goSearch() {
		var param = {
			"s_work_status_yn" : $M.getValue("s_work_status_yn"),  // 퇴사자제외
			"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
			"s_mem_name" : $M.getValue("s_apply_mem_name"),
			"s_org_code" : $M.getValue("s_org_code"),
			"s_start_dt" : $M.getValue("s_start_dt"),
			"s_end_dt" : $M.getValue("s_end_dt"),
			"s_mem_no" : $M.getValue("s_my_yn") == "Y" ? "${SecureUser.mem_no}" : "",
			"s_appr_proc_status_cd" : $M.getValue("s_appr_proc_status_cd")
		};
		_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
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
	  fnExportExcel(auiGrid, "경력증명서", exportProps);
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_apply_mem_name"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
	}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<div class="layout-box"><!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<div class="contents">		
<!-- 검색영역 -->					
                    <div class="search-wrap mt10">
                        <table class="table">
                            <colgroup>
                                <col width="65px">
                                <col width="260px">
                                <col width="40px">
                                <col width="100px">
                                <col width="50px">
                                <col width="100px">
                                <col width="50px">
                                <col width="100px">
                                <col width="110px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                                <tr>							
                                    <th>작성일자</th>	
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
										<select class="form-control" id="s_org_code" name="s_org_code">
											<option value="">- 선택 -</option>
											<c:forEach items="${orgList}" var="item">
												<option value="${item.org_code}">${item.org_name}</option>
											</c:forEach>
										</select>
                                    </td>	
                                    <th>신청자</th>
                                    <td>    
                                        <input type="text" class="form-control" id="s_apply_mem_name" name="s_apply_mem_name">
                                    </td>
                            		<th>상태</th>		
									<td>		
										<select class="form-control" id="s_appr_proc_status_cd" name="s_appr_proc_status_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['APPR_PROC_STATUS']}" var="item">
												<c:if test="${item.code_value ne '06'}">
													<option value="${item.code_value}" ${(SecureUser.appr_auth_yn == "Y" && item.code_value == "03") ? 'selected' : item.code_value == "0" ? 'selected' : '' }>${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
									</td>                                    
                                    <td class="pl15">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_work_status_yn" name="s_work_status_yn" value="Y">
											<label class="form-check-label" for="s_work_status_yn">퇴사자제외</label>
										</div>
                                    </td>		
									<td class="pl15">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_my_yn"  name="s_my_yn" value="Y">
											<label class="form-check-label" for="s_my_yn">본인 건만 조회</label>
										</div>
									</td>                                    				
                                    <td class="">
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
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<div class="form-check form-check-inline">
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								</div>
								</c:if>									
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 400px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong id="total_cnt" class="text-primary">0</strong>건
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