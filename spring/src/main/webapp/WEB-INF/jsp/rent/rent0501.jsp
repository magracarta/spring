<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 이동/재렌탈 > 센터 간 재렌탈 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		
		$(document).ready(function () {
			createAUIGrid();

			goSearch();
		});
		
		function createAUIGrid() {
			var gridPros = {
				// Row번호 표시 여부
				showRowNumColum : true,
				enableFilter : true	
			};
	
			var columnLayout = [
				{
					headerText : "관리번호",
					dataField : "rental_machine_no",
					width : "70",
					minWidth : "70",
					style : "aui-center aui-popup",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var rentalMachineNo = value;
				    	return rentalMachineNo.substring(4, 11);; 
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "소유센터",
					dataField : "own_org_name",
					style : "aui-center",
					width : "80",
					minWidth : "80",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "관리센터",
					dataField : "mng_org_name",
					style : "aui-center",
					width : "80",
					minWidth : "80",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "메이커",
					dataField : "maker_name",
					style : "aui-center",
					width : "70",
					minWidth : "60",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					style : "aui-left",
					width : "100",
					minWidth : "90",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "차대번호",
					dataField : "body_no",
					style : "aui-center aui-popup",
					width : "150",
					minWidth : "150",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "연식",
					dataField : "made_dt",  
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value.substr(0, 4);
					},
					width : "50",
					minWidth : "50",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "가동시간",
					dataField : "op_hour",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
					width : "70",
					minWidth : "70",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "번호판번호",
					dataField : "mreg_no",
					style : "aui-center",
					width : "100",
					minWidth : "90",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "접수자",
					dataField : "receipt_mem_name",
					width : "70",
					minWidth : "70",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var str = "";
						if (item.rental_center_no == "" || item.return_yn == "Y") {
							str = "";
						}  else {
							str = value;
						}
						return str;						
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "렌탈기간",
					dataField : "day_cnt",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var str = "";
						if (item.rental_center_no == "" || item.return_yn == "Y") {
							str = "";
						}  else {
							str = value + "일";
						}
						return str;						
					},
					width : "75",
					minWidth : "75",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "렌탈금액",
					dataField : "rental_amt",
					style : "aui-right",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var str = "";
						if (item.rental_center_no == "" || item.return_yn == "Y") {
							str = "";
						}  else {
							str = $M.setComma(value);
						}
						return str;						
					},
					width : "90",
					minWidth : "90",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "렌탈시작일",
					dataField : "rental_st_dt",
					dataType : "date",   
					style : "aui-center",
					width : "75",
					minWidth : "75",
					formatString : "yy-mm-dd",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var str = "";
						if (item.rental_center_no == "" || item.return_yn == "Y") {
							str = "";
						}  else {
							str = $M.dateFormat(value, 'yy-MM-dd');
						}
						return str;						
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "렌탈종료일",
					dataField : "rental_ed_dt",
					dataType : "date",   
					style : "aui-center",
					width : "75",
					minWidth : "75",
					formatString : "yy-mm-dd",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var str = "";
						if (item.rental_center_no == "" || item.return_yn == "Y") {
							str = "";
						}  else {
							str = $M.dateFormat(value, 'yy-MM-dd');
						}
						return str;						
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "상태",
					dataField : "status",
					width : "70",
					minWidth : "70",
					style : "aui-center aui-popup",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var str = "";
						if (item.rental_center_no == "" || item.return_yn == "Y") {
							str = "신청가능";
						} else {
							// TODO: 결재중, 이동신청가능, 작성중
							str = item.appr_proc_status_name;
							if (item.appr_proc_status_cd == "05" && item.return_yn == "N") {
								str = "렌탈중";
							}
						}
						return str;						
					},
					filter : {
						showIcon : true
					}
				},
				{
					dataField : "appr_proc_status_name",
					visible : false
				},
				{
					dataField : "appr_proc_status_cd",
					visible : false
				},
				{
					dataField : "return_yn",
					visible : false
				},
				{
					dataField : "rental_center_no",
					visible : false
				}
			];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			// AUIGrid.setFixedColumnCount(auiGrid, 6);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var param = {
					rental_machine_no : event.item.rental_machine_no
				};
				if(event.dataField == "rental_machine_no") { //랜탈이력팝업
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=500, left=0, top=0";
					$M.goNextPage('/rent/rent0201p04', $M.toGetParam(param), {popupStatus : poppupOption});
				}
				if(event.dataField == "body_no") {//렌탈장비대장상세팝업
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=590, left=0, top=0";
					$M.goNextPage('/rent/rent0201p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
				if(event.dataField == "status") {
					if (event.item.rental_center_no == "" || event.item.return_yn == "Y") {
						//재렌탈신청
						$M.goNextPage("/rent/rent050101", $M.toGetParam(param));
					} else {
						var params = {
							rental_center_no : event.item.rental_center_no
						}
						var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1080, height=670, left=0, top=0";
						//재렌탈신청상세팝업
						$M.goNextPage('/rent/rent0501p01', $M.toGetParam(params), {popupStatus : poppupOption});
					}
				}
			});
			
		}
		
		//엑셀다운로드버튼
		function fnDownloadExcel() {
			// 엑셀 내보내기 속성
		 	var exportProps = {
				//제외항목
			};
			fnExportExcel(auiGrid, "센터 간 재렌탈", exportProps);
		}
		
		// 검색 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_body_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		function goSearch() {
			var param = {
				s_mng_org_code : $M.getValue("s_mng_org_code"),
				s_own_org_code : $M.getValue("s_own_org_code"),
				s_maker_cd : $M.getValue("s_maker_cd"),
				s_machine_plant_seq : $M.getValue("s_machine_plant_seq"),
				s_body_no : $M.getValue("s_body_no"),
				s_status_cd : $M.getValue("s_status_cd"),
				s_made_dt : $M.getValue("s_made_dt"),
				s_sort_key : "machine_name",
				s_sort_method : "desc"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			)
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
								<col width="70px">
								<col width="80px">		
								<col width="70px">
								<col width="80px">							
								<col width="50px">
								<col width="75px">	
								<col width="40px">
								<col width="180px">	
								<col width="65px">
								<col width="100px">
								<col width="45px">
								<col width="80px">
								<col width="45px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>관리센터</th>
									<td>
										<select class="form-control width120px" alt="관리센터" id="s_mng_org_code" name="s_mng_org_code">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${orgCenterList}">
												<option value="${item.org_code}">${item.org_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>소유센터</th>
									<td>
										<select class="form-control width120px" alt="소유센터" id="s_own_org_code" name="s_own_org_code">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${orgCenterList}">
												<option value="${item.org_code}">${item.org_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>메이커</th>
									<td>
										<select class="form-control" id="s_maker_cd" name="s_maker_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MAKER']}" var="item">
												<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
													<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
									</td>
									<th>모델</th>
									<td>
										<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
											<jsp:param name="required_field" value="s_machine_name"/>
											<jsp:param name="s_sale_yn" value="N"/>
				                     	</jsp:include>
									</td>
									<th>차대번호</th>
									<td>
										<input type="text" class="form-control" id="s_body_no" name="s_body_no">
									</td>
									<th>연식</th>
									<td>
										<select class="form-control" id="s_made_dt" name="s_made_dt">
											<option value="">- 전체 -</option>
											<option value="2">2년이하</option>
											<option value="3~4">3~4년식</option>
											<option value="5~6">5~6년식</option>
											<option value="7">7년 이상</option>
										</select>
									</td>
									<th>상태</th>
									<td>
										<select class="form-control" name="s_status_cd">
											<option value="">- 전체 -</option>
											<option value="1">작성중</option>
											<option value="2" ${SecureUser.appr_auth_yn == "Y" ? 'selected' : ''}>결재중</option>
											<option value="3">신청가능</option>
											<option value="4">렌탈중</option>
										</select>
									</td>									
									<td>
										<button type="button" onclick="goSearch();" class="btn btn-important" style="width: 50px;">조회</button>
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
								<button type="button" onclick="fnDownloadExcel();" class="btn btn-default"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
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