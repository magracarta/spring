<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 발주/납기관리 > 부품발주관리 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		var apprGubun = " / ";
		
		//console.log(apprStatusCdList);
		
		<%-- 여기에 스크립트 넣어주세요. --%>
		$(document).ready(function() {
			createAUIGrid(); // 메인 그리드
			fnInit();
		});
		
		function fnInit() {
			/* var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1)); */
			//goSearch();
		}
		
		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				//체크박스 출력 여부
				showRowCheckColumn: true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				showRowNumColumn: true,
				enableSorting : true,
				// 전체선택 체크박스가 독립적인 역할을 할지 여부
				independentAllCheckBox : true,
				rowCheckableFunction : function(rowIndex, isChecked, item) {
					/* if(item.part_order_status_cd == "0") {
						alert("진행상태가 \"발주\"인 자료만 선택 가능합니다.");
						return false;
					} */
					if(item.part_order_status_cd != "3" && item.part_order_status_cd != "9") {
						alert("진행상태가 \"발주\"인 자료만 선택 가능합니다.");
						return false;
					}
					/* if(item.part_order_status_cd == "2") {
						alert("발주 또는 마감 상태만 선택할 수 있습니다.");
						return false;
					} */
					return true;
				},
			};
			var columnLayout = [
				{
					dataField : "part_order_no",
					visible : false
				},
				{ 
					headerText : "발주번호", 
					dataField : "dis_part_order_no", 
					style : "aui-popup",
					width : "95",
					minWidth : "95",
				},
				{
					dataField : "part_order_status_cd",
					visible : false
				},
				{ 
					headerText : "발주등록일", 
					dataField : "reg_dt",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "70",
					minWidth : "70",
				},
				{ 
					headerText : "발주처리일", 
					dataField : "order_proc_dt",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "70",
					minWidth : "70",
				},
				{ 
					headerText : "발주처", 
					dataField : "cust_name", 
					width : "105",
					minWidth : "95",
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					style : "aui-left",
					width : "120",
					minWidth : "110",
				},
				{ 
					headerText : "적요", 
					dataField : "desc_text",
					width : "170",
					minWidth : "105",
				},
				{ 
					headerText : "금액", 
					dataField : "total_amt", 
					width : "80",
					minWidth : "75",
					dataType : "numeric",
					style : "aui-right"
				},
				{ 
					headerText : "담당자", 
					dataField : "reg_mem_name", 
					width : "55",
					minWidth : "50",
				},
				{ 
					headerText : "결재", 
					dataField : "path_mem_appr_status_name",
					style : "aui-left",
					width : "240",
					minWidth : "100",
				},
				{ 
					headerText : "상태", 
					dataField : "part_order_status_name", 
					width : "85",
					minWidth : "55"
				},
				{ 
					headerText : "센터부품할당", 
					dataField : "warehouse_name", 
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var temp = value == "" || value == null ? "" : value.split("|");
						if (temp.length > 1) {
							temp = temp[0] + " 외 "+(temp.length-1)+"건"; 
						} 
			            return temp;
					},
					width : "100",
					minWidth : "65"
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.resize(auiGrid);
			// AUIGrid.setFixedColumnCount(auiGrid, 6);
			// 전체 체크박스 클릭 이벤트 바인딩
			AUIGrid.bind(auiGrid, "rowAllChkClick", function( event ) {
				if(event.checked) {
					// 작성중, 결재중, 결재완료 항목은 제외
					var uniqueValues = AUIGrid.getColumnDistinctValues(event.pid, "part_order_status_cd");
					for (var i = 0; i < uniqueValues.length; ++i) {
						if (uniqueValues[i] == "0") {
							uniqueValues.splice(i,1);
						}
						if (uniqueValues[i] == "1") {
							uniqueValues.splice(i,1);
						}
						if (uniqueValues[i] == "2") {
							uniqueValues.splice(i,1);
						}
					}
					AUIGrid.setCheckedRowsByValue(event.pid, "part_order_status_cd", uniqueValues);
				} else {
					AUIGrid.setCheckedRowsByValue(event.pid, "part_order_status_cd", []);
				}
			});
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == 'dis_part_order_no'){
					var param = {
							part_order_no : event.item.part_order_no
					};
					var poppupOption = "";
					$M.goNextPage('/part/part0403p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
		}
		
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			};
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {				
				return;
			}; 
			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_cust_no : $M.getValue("s_cust_no"),
				s_part_order_status_cd : $M.getValue("s_part_order_status_cd"),
				s_sort_key : "part_order_no",
				s_sort_method : "desc"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						console.log(result.list);
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		// 엑셀다운로드
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {};
			  fnExportExcel(auiGrid, "부품발주내역", exportProps);
		}
		
		function goDone() {
			goFinish('deadline');
		}
		
		function goCancelDone() {
			goFinish('cancelDeadline');
		}
		
		function goFinish(type) {
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (rows.length == 0) {
				alert("선택된 자료가 없습니다.");
				return false;
			}
			var param = {
				"type" : type,
				"part_order_no" : $M.getArrStr(rows, {key : "part_order_no", isEmpty : true})
			};
			var msg = "마감하시겠습니까?";
			if (type != "deadline") {
				msg = "마감취소하시겠습니까?";
			}
			$M.goNextPageAjaxMsg(msg, this_page + "/finish", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch();
					}
				}
			);
		}
		
		function goNew() {
			/* alert("오류 수정중입니다.");
			return false; */
			var param = {};
			var poppupOption = "";
			$M.goNextPage('/part/part040301', $M.toGetParam(param), {popupStatus : poppupOption});
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
								<col width="40px">
								<col width="100px">
								<col width="80px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="rs">발주일자</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate rb" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" required="required" value="${searchDtMap.s_start_dt }">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate rb" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" required="required" value="${searchDtMap.s_end_dt }">
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
									<th>발주처</th>
									<td>
										<div class="input-group">
											<input type="text" style="width : 220px";
												id="s_cust_no" 
												name="s_cust_no" 
												idfield="cust_no"
												easyui="combogrid"
												header="Y"
												easyuiname="combogrid" 
												panelwidth="370"
												maxheight="200"
												enter="goSearch()"
												textfield="cust_name"
												multi="N"/>
										</div>
									</td>
									<th>진행상태</th>
									<td>
										<select class="form-control" id="s_part_order_status_cd" name="s_part_order_status_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="list" items="${codeMap['PART_ORDER_STATUS']}">
											<option value="${list.code_value}" ${(SecureUser.appr_auth_yn == "Y" && list.code_value == "1") ? 'selected' : ''}>${list.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
									</td>			
								</tr>										
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>발주목록</h4>
						<div class="btn-group">
							<div class="right">
								<span class="text-warning">※ &lt;마감&gt; 는 진행상태가 "발주"에서만 가능합니다.</span>
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
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>