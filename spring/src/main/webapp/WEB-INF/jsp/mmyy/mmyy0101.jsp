<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 공지사항 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var orgCodeArr = [];
		var jobCdArr = [];
		var gradeCdArr = [];
		
		$(document).ready(function() {
			createLeftAUIGrid();
			createRightAUIGrid();
			fnInit();
			goSearch();
		});

		function fnInit() {
			var now = "${inputParam.s_current_dt}";
			// $M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -3));
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_title", "s_reg_mem_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch('');
				};
			});
		}
		
		// 메뉴 트리 그리드
		function createLeftAUIGrid() {
			var gridPros = {
				rowIdField : "menu_code",
				displayTreeOpen :true,
				rowCheckDependingTree : true,
				showRowNumColumn: false,
				enableFilter :true,
			};
			var columnLayout = [
				{ 
					headerText : "카테고리구분", 
					dataField : "menu_name", 
// 					width : "310",  
// 					minWidth : "50",
					style : "aui-left",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					dataField : "menu_code", 
					visible : false,
				}
			];
			
			auiLeftGrid = AUIGrid.create("#auiLeftGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiLeftGrid, ${list});
			$("#auiLeftGrid").resize();
			AUIGrid.bind(auiLeftGrid, "cellClick", function(event){
				var menuCode = event.item["menu_code"];
				goSearch(menuCode);      
			});
		}

		//그리드셀 클릭시
	   function goSearch(menuCode) {
			if(menuCode == null || menuCode == undefined) {
				menuCode = "";
			}
			var params = {
					"menu_code" : menuCode,
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_end_dt" : $M.getValue("s_end_dt"),
					"s_title" : $M.getValue("s_title"),
					"s_reg_mem_name" : $M.getValue("s_reg_mem_name"),
					"s_show_ed_dt" : $M.getValue("s_show_ed_dt"),
					"s_search_type" : "Y",
					"s_must_yn" : $M.getValue("s_must_yn"),
					"s_sort_key" : "view_yn asc, reg_date",
					"s_sort_method" : "desc"
				};
		   _fnAddSearchDt(params, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), { method : 'get'},
				function(result) {
					if(result.success) { 
						AUIGrid.setGridData(auiRightGrid, result.mainList);
						AUIGrid.setGridData(auiLeftGrid, result.list);
						AUIGrid.expandAll(auiRightGrid);
						$("#total_cnt").html(result.total_cnt);
					}
				}
			);
		}
		
		// 공지사항 리스트
		function createRightAUIGrid() {
			var gridPros = {
				rowIdField : "notice_seq",
				rowCheckDependingTree : true,
				showRowNumColumn: false,
				enableFilter :true,
				
			};
			var columnLayout = [
				{
					dataField : "view_yn", 
					visible : false
				},
				{
					dataField : "notice_seq", 
					visible : false
				},
				{ 
					headerText : "구분", 
					dataField : "menu_name", 
					width : "170",
					minWidth : "50", 
					style : "aui-center",
					editable : false,               
					filter : {
		                  showIcon : true
		            }
				},
				{ 
					headerText : "제목", 
					dataField : "title", 
					width : "380",
					minWidth : "50", 
					style : "aui-left aui-popup",
					editable : false,               
					filter : {
		                  showIcon : true
		            },
					renderer : {
						type : "TemplateRenderer"
					},
					/* labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						if(item["view_yn"] == "N") {
							var template = '<div>' + '<span style="color:red";>' + item.title + '</span>' + '</div>';
							return template;
						} else {
						   var template = '<div>' + item.title + '</div>';
						   return template;
						}
					} */
				},
				{ 
					headerText : "첨부파일", 
					dataField : "file_yn", 
					width : "70",
					minWidth : "50", 
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "작성일", 
					dataField : "reg_date",
					dataType : "date",
					formatString : "yy-mm-dd", 
					width : "90",
					minWidth : "50", 
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "작성자", 
					dataField : "reg_mem_name", 
					width : "100",
					minWidth : "50", 
					style : "aui-center",
					editable : false,               
					filter : {
		                  showIcon : true
		            }
				},
				{
					headerText : "마감일", 
					dataField : "show_ed_dt", 
					dataType : "date",
					formatString : "yy-mm-dd", 
					width : "90",
					minWidth : "50", 
					style : "aui-center",
				},
				{
					headerText : "필독",
					dataField : "must_read_yn",
					width : "40",
					minWidth : "40", 
				},
				{
					headerText : "조회수", 
					dataField : "read_cnt",
					width : "80",
					minWidth : "50", 
					style : "aui-center",
				},
				{
					dataField : "menu_code", 
					visible : false,
				}
			];
			
			auiRightGrid = AUIGrid.create("#auiRightGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiRightGrid, []);
			$("#auiRightGrid").resize();
			AUIGrid.bind(auiRightGrid, "cellClick", function(event){
				if(event.dataField == "title") {
					var param = {
						"notice_seq" : event.item["notice_seq"]
					};
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=850, height=800, left=0, top=0";
					$M.goNextPage('/mmyy/mmyy0101p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
				
			});
		}
		
		// 공지사항 등록 페이지 이동
		function goNew() {
			$M.goNextPage("/mmyy/mmyy010101");
		}
		
		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiRightGrid, "공지사항", exportProps);
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
								<col width="60px">
								<col width="260px">								
								<col width="45px">
								<col width="120px">
								<col width="55px">
								<col width="120px">
								<col width="110px">
								<col width="130px">
							</colgroup>
							<tbody>
								<tr>
									<th>작성일자</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width110px">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd"  value="${searchDtMap.s_start_dt}" alt="요청 시작일">
												</div>
											</div>
											<div class="col width16px text-center">~</div>
											<div class="col width120px">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd"  value="${searchDtMap.s_end_dt}" alt="요청 완료일">
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
									<th>제목</th>
									<td>
										<input type="text" class="form-control" id="s_title" name="s_title">
									</td>
									<th>작성자</th>
									<td>
										<input type="text" class="form-control" id="s_reg_mem_name" name="s_reg_mem_name">
									</td>
									<td class="pl10">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_show_ed_dt" name="s_show_ed_dt" value="Y" checked="checked">
											<label class="form-check-label" for="s_show_ed_dt">마감자료포함</label>
										</div>
									</td>
									<td class="pl10">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_must_yn" name="s_must_yn" value="Y">
											<label class="form-check-label" for="s_must_yn">필독공지만 조회</label>
										</div>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch('');">조회</button>
									</td>									
								</tr>						
							</tbody>
						</table>					
					</div>
					<!-- /검색영역 -->
					<div class="row">
						<div class="col-3">
					<!-- 카테고리 -->
							<div class="title-wrap mt10">
								<h4>카테고리</h4>
								<div class="btn-group">
									<div class="right">
										<button type="button" onclick=AUIGrid.expandAll(auiLeftGrid); class="btn btn-default"><i class="material-iconsadd text-default"></i>펼침</button>
										<button type="button" onclick=AUIGrid.collapseAll(auiLeftGrid); class="btn btn-default"><i class="material-iconsremove text-default"></i>접힘</button>
									</div>
								</div>
							</div>
							<div id="auiLeftGrid" style="margin-top: 5px;height: 550px;"></div>
					<!-- /카테고리 -->
						</div>
						<div class="col-9">
					<!-- 조회결과 -->
							<div class="title-wrap mt10">
								<h4>조회결과</h4>
								<div class="btn-group">
									<div class="right">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
									</div>
								</div>
							</div>
							<div id="auiRightGrid" style="margin-top: 5px; height:550px;"></div>
							<div class="btn-group mt5">
								<div class="left">
									총 <strong class="text-primary" id="total_cnt">0</strong>건
								</div>	
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
								</div>	
							</div>	
					<!-- /조회결과 -->		
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