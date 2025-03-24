<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 로그정보 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-03-11 15:00:43
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGrid();
		});
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "로그정보", "");
		}
		
		function enter(fieldObj) {
			var field = ["s_mem_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
				// 전체 체크박스 표시 설정
				//체크박스 출력 여부
				/* showRowCheckColumn: true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true, */
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText: "계정아이디",
				    dataField: "web_id",
					width : "100",
					minWidth : "50",
				},
				{
					headerText: "사번",
				    dataField: "mem_no",
					width : "100",
					minWidth : "50",
				},
				{
					headerText: "직원구분",
				    dataField: "mem_type_name",
					width : "60",
					minWidth : "30",
				},
				{
					headerText: "직원명",
				    dataField: "kor_name",
					width : "60",
					minWidth : "50",
				},
				{
					headerText : "부서", 
					dataField : "org_name", 
					width : "50",
					minWidth : "50",
				},
				{
					headerText : "직위", 
					dataField : "grade_name", 
					width : "50",
					minWidth : "50",
				},
				{
					headerText : "직급",
					dataField : "job_name", 
					width : "50",
					minWidth : "50",
				},
				{
					headerText : "휴대전화", 
					dataField : "hp_no", 
					width : "100",
					minWidth : "50",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return $M.phoneFormat(value)
					},
				},
				{
					headerText : "이메일", 
					dataField : "email", 
					width : "120",
					minWidth : "50",
				},
				{
					headerText : "재직구분", 
					dataField : "work_status_name", 
					width : "60",
					minWidth : "50",
				},
				{
					headerText : "접속IP", // (기간 중 가장최근것 하나만 가져옴)
					dataField : "ctrl_ip",
					width : "100",
					minWidth : "50",
				},
				{
					headerText : "로그시작일시", // (기간 중 min 값)
					dataField : "log_st_date",
					width : "130",
					minWidth : "50",
				},
				{
					headerText : "로그종료일시", // (기간 중 max 값)
					dataField : "log_ed_date",
					width : "130",
					minWidth : "50",
				},
				{
					headerText : "Page View",
					dataField : "page_view_cnt",
					style : "aui-popup",
					width : "100",
					minWidth : "50",
				},
				{
					headerText : "Download",
					dataField : "excel_down_cnt",
					style : "aui-popup",
					width : "100",
					minWidth : "50",
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == 'page_view_cnt' || event.dataField == 'excel_down_cnt'){
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=700, left=0, top=0";
					var param = {
						s_start_dt : $M.getValue("s_start_dt"),
						s_end_dt : $M.getValue("s_end_dt"),
						mem_no : event.item.mem_no,
						log_st_date : event.item.log_st_date,
						log_ed_date : event.item.log_ed_date,
						org_name : event.item.org_name,
						kor_name : event.item.kor_name,
					}
					$M.goNextPage('/comm/comm0118p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.resize(auiGrid);
		}
		
		// 조회
		function goSearch() {
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {				
				return;
			}; 
			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_mem_name : $M.getValue("s_mem_name"),
				s_org_code : $M.getValue("s_org_code"),
				s_mem_type_cd : $M.getValue("s_mem_type_cd"),
				s_work_status_cd : $M.getValue("s_work_status_cd"),
				s_sort_key : "m.mem_no",
				s_sort_method : "desc"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						AUIGrid.resize(auiGrid);
						if (result.list) {
							$("#total_cnt").html(result.list.length);
						}
					};
				}
			);
		}
		
	</script>
</head>
<body>
	<form id="main_form" name="main_form">
	<input type="hidden" id="clickedRowIndex" name="clickedRowIndex">
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
<!-- 기본 -->					
					<div class="search-wrap">
                        <table class="table">
                            <colgroup>
                            	<col width="60px">
								<col width="260px">	
                                <col width="55px">
                                <col width="120px">
                                <col width="50px">
                                <col width="120px">
                                <col width="75px">
                                <col width="120px">
                                <col width="75px">
                                <col width="120px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                                <tr>
                                	<th class="rs">로그일자</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="로그시작일" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}" alt="로그종료일">
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
                                    <th>직원명</th>	
                                    <td>
                                        <input type="text" class="form-control" id="s_mem_name" name="s_mem_name">
                                    </td>
                                    <th>부서</th>
                                    <td>
                                        <input class="form-control" style="width: 99%;"type="text" id="s_org_code" name="s_org_code" easyui="combogrid"
												easyuiname="pathOrgList" panelwidth="350" idfield="org_code" textfield="path_org_name" multi="N"/>
                                    </td>		
                                    <th>직원구분</th>
                                    <td>    
                                        <select class="form-control" id="s_mem_type_cd" name="s_mem_type_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="list" items="${codeMap['MEM_TYPE']}">
												<option value="${list.code_value}">${list.code_name}</option>
											</c:forEach>
										</select>
                                    </td>		
                                    <th>재직구분</th>
                                    <td>    
                                        <select class="form-control" id="s_work_status_cd" name="s_work_status_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="list" items="${codeMap['WORK_STATUS']}">
												<option value="${list.code_value}" <c:if test="${list.code_value eq '01'}">selected</c:if>>${list.code_name}</option>
											</c:forEach>
										</select>
                                    </td>						
                                    <td class="">
                                        <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
                                    </td>
                                </tr>							
                            </tbody>
                        </table>
                    </div>
<!-- /기본 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>		
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
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