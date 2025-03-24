<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비선적발주 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		<%-- 여기에 스크립트 넣어주세요. --%>
		$(document).ready(function() {
			fnInit();
			// AUIGrid 생성
			createAUIGrid();
		});
		
		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
			goSearch();
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
				treeColumnIndex : 1,
				displayTreeOpen : true,
				enableFilter :true,
				height : 550,
				headerHeight : 40
			};
			var columnLayout = [
				{
					headerText : "등록일", 
					dataField : "reg_date", 
					dataType : "date",  
					formatString : "yy-mm-dd",
					width : "65",
					minWidth : "30",
					style : "aui-center"
				},
				{ 
					headerText : "발주번호", 
					dataField : "machine_no", 
					width : "120",
					minWidth : "30", 
					style : "aui-center",
					filter : {
						showIcon : true
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value.substring(7);
					}
				},
				{ 
					headerText : "발주처", 
					dataField : "cust_name", 
					width : "110",
					minWidth : "30",
					style : "aui-center"
				},
				{ 
					headerText : "발주내역", 
					dataField : "machine_name", 
					style : "aui-left aui-popup",
					width : "480",
					minWidth : "30",
				},
				{ 
					headerText : "전체<br>수량", 
					dataField : "qty", 
					dataType : "numeric",
					width : "40",
					minWidth : "30",
					style : "aui-center",
				},
				{ 
					headerText : "합계금액", 
					dataField : "total_amt", 
					dataType : "numeric",
					formatString : "#,##0.00",
					width : "100",
					minWidth : "30",
					style : "aui-right"
				},
				{ 
					headerText : "화폐<br>단위", 
					dataField : "money_unit_cd", 
					width : "50",
					minWidth : "30",
					style : "aui-center"
				},
				{ 
					headerText : "담당자", 
					dataField : "reg_mem_name",
					width : "50",
					minWidth : "30",
					style : "aui-center"
				},
				{ 
					headerText : "결재", 
					width : "200",
					minWidth : "30", 
					dataField : "path_appr_job_status_name", 
					style : "aui-left"
				},
				{ 
					headerText : "상태", 
					width : "50",
					minWidth : "30",
					dataField : "appr_proc_status_name", 
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var appr_proc_status_name = value;
						if(item["seq_depth"] != "1") {
							appr_proc_status_name = "-"
						}
						return appr_proc_status_name;
					}
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			// 발주내역 클릭시 -> 발주서상세 팝업 호출
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "machine_name") {
					// event.seq_depth == 1 -> 선적발주상세 2 -> 생산발주상세
					if(event.item.seq_depth == 1) {
						var params = {
							machine_ship_no : event.item.machine_ship_no
						};
// 						var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1650, height=910, left=0, top=0";
						var popupOption = "";
						$M.goNextPage('/sale/sale0202p01', $M.toGetParam(params), {popupStatus : popupOption});
					} else {
						console.log(event);
						var params = {
								machine_order_no : event.item.machine_order_no
						}
// 						var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1650, height=910, left=0, top=0";
						var popupOption = "";
						$M.goNextPage('/sale/sale0201p01', $M.toGetParam(params), {popupStatus : popupOption});
					};
				}
			});	
		}
		
		// 조회
		function goSearch() {
			var param = {
					s_machine_ship_no : $M.getValue("s_machine_ship_no"),
// 					s_cust_no : $M.getValue("s_cust_no"),
					s_cust_name : $M.getValue("s_cust_name"),
					s_appr_proc_status_cd : $M.getValue("s_appr_proc_status_cd"),
					s_start_dt : $M.getValue("s_start_dt"),
					s_end_dt : $M.getValue("s_end_dt")
// 					s_sort_key : "reg_date",
// 					s_sort_method : "desc"
				};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						console.log(result);
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}		
			);
		}
		
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "장비선적발주", exportProps);
		}
		
		// 선적발주등록 페이지 이동
		function goNew() {
			$M.goNextPage("/sale/sale020201");
		}
		
		// 매입처조회 팝업
		function fnSearchClientComm() {
			var param = {
					's_cust_name' : $M.getValue('s_cust_name'),
			};
			openSearchClientPanel('fnSetClientInfo', 'comm', $M.toGetParam(param));
		}
		
		// 매입처 정보 세팅
		function fnSetClientInfo(row) {
			console.log(row);
			$M.setValue("s_cust_name", row.cust_name);
			$M.setValue("s_cust_no", row.cust_no);
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_machine_ship_no"];
			var custField = ["s_cust_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
			$.each(custField, function() {
				if(fieldObj.name == this) {
					fnSearchClientComm();
				};
			});
		}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="s_cust_no" name="s_cust_no">
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
								<col width="50px">
								<col width="100px">
								<col width="60px">
								<col width="150px">
								<col width="50px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>등록일</th>
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
									<th>발주번호</th>
									<td>
										<div class="icon-btn-cancel-wrap">
											<input type="text" class="form-control" id="s_machine_ship_no" name="s_machine_ship_no">
										</div>
									</td>
									<th>발주처</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0" id="s_cust_name" name="s_cust_name">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
										</div>
									</td>
									<th>상태</th>
									<td>
										<select class="form-control" id="s_appr_proc_status_cd" name="s_appr_proc_status_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['APPR_PROC_STATUS']}" var="item">
												<option value="${item.code_value}" ${(SecureUser.appr_auth_yn == "Y" && item.code_value == "03") ? 'selected' : item.code_value == "0" ? 'selected' : ''}>${item.code_name}</option>
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
						<h4>선적발주내역</h4>
						<div class="btn-group">
							<div class="right">
								<button type="button" onclick=AUIGrid.expandAll(auiGrid); class="btn btn-default"><i class="material-iconsadd text-default"></i>전체펼치기</button>
								<button type="button" onclick=AUIGrid.collapseAll(auiGrid); class="btn btn-default"><i class="material-iconsremove text-default"></i>전체접기</button>							
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong id="total_cnt" class="text-primary">0</strong>건
						</div>						
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>