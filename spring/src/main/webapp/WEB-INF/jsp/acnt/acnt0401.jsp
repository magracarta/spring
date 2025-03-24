<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 장비입고관리-통관 > null > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
// 			fnInit();	
			// AUIGrid 생성
			createAUIGrid();
			goSearch();
		});
		
// 		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -12));
// 		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				treeColumnIndex : 0,
				displayTreeOpen : true,
				editable : false,
				enableFilter :true,
				enableMovingColumn : false,
				height : 550,
			};
			var columnLayout = [
				{
					headerText : "관리번호", 
					dataField : "machine_no", 
					width : "160",
					minWidth : "80",
					style : "aui-left",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (item["seq_depth"] == "1") {
							return "aui-popup"
						}
						return null;
					},
					filter : {
						showIcon : true
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						if (item["seq_depth"] == "1") {
							return value.substring(7);
						}
						return value;
					}
				},
				{ 
					headerText : "작성일", 
					dataField : "reg_date", 
					dataType : "date",  
					formatString : "yy-mm-dd",
					width : "80",
					minWidth : "80",
					style : "aui-center"
				},
				{ 
					headerText : "발주처",
					dataField : "client_cust_name",
					width : "100",
					minWidth : "80",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var desc_text = value;
						if(item["seq_depth"] != "1") {
							desc_text = "-"
						}
						return desc_text;
					}
				},
				{
					headerText : "발주내역", 
					dataField : "machine_name", 
					style : "aui-left",
					width : "300",
					minWidth : "50",
				},
				{
					headerText : "비고(참고)", 
					dataField : "pass_remark", 
					style : "aui-left",
					width : "320",
					minWidth : "50",
				},
				{ 
					headerText : "합계금액", 
					dataField : "total_amt", 
					dataType : "numeric",
					formatString : "#,##0.00",
					width : "100",
					minWidth : "100",
					style : "aui-right",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var desc_text = $M.numberFormat(value);
						if(item["seq_depth"] != "1") {
							desc_text = "-"
						}
						return desc_text;
					}
				},
				{ 
					headerText : "상태", 
					dataField : "status_name", 
					width : "60",
					minWidth : "60",
					style : "aui-center",
				},
// 				{ 
// 					headerText : "송금완료여부", 
// 					dataField : "remit_proc_yn", 
// 					width : "5%", 
// 					style : "aui-center",
// 				},
				{ 
					headerText : "송금완료일", 
					dataField : "remit_proc_date",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "80",
					minWidth : "80",
					style : "aui-center",
				},
				{ 
					headerText : "통관일", 
					dataField : "pass_dt", 
					style : "aui-center",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "80",
					minWidth : "80",
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 						var desc_text = AUIGrid.formatDate(value, "yyyy-mm-dd");
// 						if(item["pass_yn"] != "Y") {
// 							desc_text = "-"
// 						}
// 						return desc_text;
// 					}
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			// 관리번호 클릭시 -> 장비통관 팝업 호출
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "machine_no" ) {
					var params = {
							machine_lc_no : event.item.machine_lc_no,
							s_sort_key : "container_seq",
							s_sort_method : "asc"
					}
					
					var popupOption = "";
					$M.goNextPage("/acnt/acnt0401p04", $M.toGetParam(params), {popupStatus : popupOption});
// 					$M.goNextPage("/acnt/acnt0401p04", $M.toGetParam(param));
				}
			});	
			
 		    // 구해진 칼럼 사이즈를 적용 시킴.
// 			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
// 		    AUIGrid.setColumnSizeList(auiGrid, colSizeList);
		}
		
		// 엑셀 다운로드
		function fnDownloadExcel() {
			  fnExportExcel(auiGrid, "장비입고관리-통관");
		}
		
		// 조회
		function goSearch() {
			var param = {
				"s_start_dt" : $M.getValue("s_start_dt")
				, "s_end_dt" : $M.getValue("s_end_dt")
				, "s_machine_lc_status_cd" : $M.getValue("s_machine_lc_status_cd")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
						AUIGrid.collapseAll(auiGrid);
					}
				}
			);
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
								<col width="260px">								
								<col width="45px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>작성일자</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" value="${searchDtMap.s_start_dt}">
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
									<th>상태</th>
									<td>
										<select class="form-control" id="s_machine_lc_status_cd" name="s_machine_lc_status_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MACHINE_LC_STATUS']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
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
								<button type="button" onclick=AUIGrid.expandAll(auiGrid); class="btn btn-default"><i class="material-iconsadd text-default"></i>전체펼치기</button>
								<button type="button" onclick=AUIGrid.collapseAll(auiGrid); class="btn btn-default"><i class="material-iconsremove text-default"></i>전체접기</button>							
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong id="total_cnt" class="text-primary">0</strong>건
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