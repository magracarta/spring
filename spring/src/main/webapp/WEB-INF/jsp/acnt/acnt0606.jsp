<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 연봉관리 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;
	
	$(document).ready(function() {
		// 그리드 생성
		createAUIGrid();
		goSearch();
	});
	
	function goNew() {
		var url = "/acnt/acnt060601";
		var param = {};
		$M.goNextPage(url, $M.toGetParam(param), {});
	}
	
	// 그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : true,
			enableFilter :true,
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				dataField : "mem_year_salary_no",
				visible : false
			},
			{
				dataField : "mem_no",
				visible : false
			},
			{
				headerText: "부서",
				dataField: "org_name",
				width : "70",
				style : "aui-center",
			},
			{
				headerText: "직원명",
				dataField: "mem_name",
				width : "60",
				style : "aui-center aui-popup",
			},
			{
				headerText: "직책",
				dataField: "grade_name",
				width : "80",
				style : "aui-center",
			},
			{
				headerText: "직급",
				dataField: "job_name",
				width : "80",
				style : "aui-center",
			},
			{
				headerText: "계정아이디",
				dataField: "web_id",
				width : "80",
				style : "aui-center",
			},
			{
				headerText: "사번",
				dataField: "emp_id",
				width : "70",
				style : "aui-center",
			},
			{
				headerText: "평가연봉",
				dataField: "last_salary_amt",
				dataType : "numeric",
				formatString : "#,##0",
				width : "90",
				style : "aui-right",
			},
			{
				headerText: "진행상태",
				dataField: "proc_status_name",
				width : "80",
				style : "aui-center",
			},
			{
				headerText: "시작일",
				dataField: "contract_st_dt",
				dataType: "date",
				width : "85",
				style : "aui-center",
				formatString: "yyyy-mm-dd",
			},
			{
				headerText: "종료일",
				dataField: "contract_ed_dt",
				dataType: "date",
				width : "85",
				style : "aui-center",
				formatString: "yyyy-mm-dd",
			},
			{
				headerText: "기본급",
				dataField: "base_salary_amt",
				dataType : "numeric",
				formatString : "#,##0",
				width : "100",
				style : "aui-right",
			},
			{
				headerText: "연장근로수당",
				dataField: "over_salary_amt",
				dataType : "numeric",
				formatString : "#,##0",
				width : "90",
				style : "aui-right",
			},
			{
				headerText: "통상임금",
				dataField: "norm_salary_amt",
				dataType : "numeric",
				formatString : "#,##0",
				width : "90",
				style : "aui-right",
			},
			{
				headerText: "월간급여",
				dataField: "mon_salary_amt",
				dataType : "numeric",
				formatString : "#,##0",
				width : "90",
				style : "aui-right",
			},
			{
				headerText: "확정연봉",
				dataField: "total_salary_amt",
				dataType : "numeric",
				formatString : "#,##0",
				width : "100",
				style : "aui-right",
			},
			{
				headerText: "계약서",
				dataField: "complete_yn",
				width : "50",
				style : "aui-center",
				labelFunction : function(rowIndex, columnIndex, value, item){
					var ret = "미 완료";
					if (value == "Y") {
						ret = "완료";
					}
					return ret;
				}
			},
			{
				headerText: "비고",
				dataField: "remark",
				width : "120",
				style : "aui-left",
			},
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, []);
		$("#auiGrid").resize();
		
		// 연봉상세 팝업 호출
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "mem_name") {
				console.log("event : ", event);
				var param = {
					mem_year_salary_no : event.item.mem_year_salary_no
				};
				var poppupOption = "";
				$M.goNextPage('/acnt/acnt0606p01', $M.toGetParam(param), {popupStatus : poppupOption});
			}
		});
	}
	
	function goSearch() {
		if ($M.getValue("s_end_year") < $M.getValue("s_start_year")) {
			alert("조회년도를 다시 설정하세요.");
			return false;
		}
		var param = {
				"s_work_status_yn" : $M.getValue("s_work_status_yn"),  // 퇴사자제외
				"s_now_contract" : $M.getValue("s_now_contract"),
				"s_no_date_yn" : $M.getValue("s_no_date_yn"),
				"s_start_year" : $M.getValue("s_start_year"),
				"s_end_year" : $M.getValue("s_end_year"),
				"s_mem_name" : $M.getValue("s_mem_name"),
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
	function fnDownloadExcel() {
	  // 엑셀 내보내기 속성
	  var exportProps = {};
	  fnExportExcel(auiGrid, "연봉관리", exportProps);
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
                                <col width="110px">
                                <col width="135px">
                                <col width="170px">
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
	                                                    <c:set var="year_option" value="${inputParam.s_current_year - i + 2001}"/>
	                                                    <option value="${year_option}" <c:if test="${year_option eq inputParam.s_current_year-1}">selected</c:if>>${year_option}년</option>
	                                                </c:forEach>
												</select>
	                                        </div>
	                                        <div class="col-auto text-center">~</div>
	                                        <div class="col-auto">
												<select class="form-control" id="s_end_year" name="s_end_year">
													<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
	                                                    <c:set var="year_option" value="${inputParam.s_current_year - i + 2001}"/>
	                                                    <option value="${year_option}" <c:if test="${year_option eq inputParam.s_current_year}">selected</c:if>>${year_option}년</option>
	                                                </c:forEach>
												</select>
	                                        </div>
	                                    </div>
                                    </td>
                                    <th>부서</th>
                                    <td>
                                        <select class="form-control" id="s_org_code" name="s_org_code">
                                        	<c:choose>
                                        		<c:when test="${page.fnc.F02090_001 eq 'Y'}">
                                        			<option value="">- 전체 -</option>
													<c:forEach items="${orgList}" var="item">
														<option value="${item.org_code}">${item.org_name}</option>
													</c:forEach>
                                        		</c:when>
                                        		<c:otherwise>
                                        			<c:choose>
                                        				<c:when test="${page.fnc.F02090_002 eq 'Y'}">
                                        					<c:forEach items="${orgList}" var="item">
			                                        			<c:if test="${fn:startsWith(item.org_code, '5')}">
			                                        				<option value="${item.org_code}">${item.org_name}</option>
			                                        			</c:if>
															</c:forEach>
                                        				</c:when>
														<c:when test="${page.fnc.F02090_003 eq 'Y'}">
															<c:forEach items="${orgList}" var="item">
																<c:set var="orgCodePart" value="${orgCodePart}"/>
																<c:if test="${fn:startsWith(item.org_code, '5') || (item.org_code eq orgCodePart)}">
																	<option value="${item.org_code}">${item.org_name}</option>
																</c:if>
															</c:forEach>
														</c:when>
                                        				<c:otherwise>
                                        					<option value="${SecureUser.org_code}">${SecureUser.org_name}</option>
                                        				</c:otherwise>
                                        			</c:choose>
                                        		</c:otherwise>
                                        	</c:choose>
										</select>
                                    </td>		
                                    <th>직원명</th>
                                    <td>    
                                        <input type="text" class="form-control" id="s_mem_name" name="s_mem_name">
                                    </td>			
                                    <td class="pl15">
                                        <div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_work_status_yn" name="s_work_status_yn" value="Y" checked="checked">
											<label class="form-check-label" for="s_work_status_yn">퇴사자제외</label>
										</div>
                                    </td>
                                    <td class="pl15">
                                        <div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_now_contract" name="s_now_contract" value="Y" checked="checked">
											<label class="form-check-label" for="s_now_contract">최근 계약만 조회</label>
										</div>
                                    </td>
                                    <td class="pl15">
                                        <div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_no_date_yn" name="s_no_date_yn" value="Y" checked="checked">
											<label class="form-check-label" for="s_no_date_yn">계약기간 없는것 포함</label>
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
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
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