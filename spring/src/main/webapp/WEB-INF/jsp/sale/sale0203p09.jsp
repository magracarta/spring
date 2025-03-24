<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비입고-LC Open 선적 > null > 입고일정
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-08-09 17:17:08
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;
	
	$(document).ready(function() {
		createAUIGrid();
		goSearch();
		
	});
	
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid", 
			// rowNumber 
			showRowNumColumn: false,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			showStateColumn : false,
			editable : false,
			enableCellMerge : true,
  			cellMergeRowSpan:  true,
  			// 센터 합계 표시 row는 푸터스타일 적용
			rowStyleFunction : function(rowIndex, item) { 
				if (item.container_seq == "0") {
					return "aui-background-darkgray";
				} else {
					return "";
				};
			}
		};
		
		var columnLayout = []; 
		
		// 실제로 #grid_wrap 에 그리드 생성
 		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, []);
	}	
	
	// 조회
	function goSearch() {
		var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_maker_cd : $M.getValue("s_maker_cd"),
				s_center_confirm_yn : $M.getValue("s_center_confirm_yn")
		};
		_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					fnResult(result);
				};
			}		
		);
	}
	
	// 조회 후 그리드 갱신
	function fnResult(result) {
		if (result.success) {
			var columnLayout = [
				{ 
					headerText : "확정취소", 
					dataField : "machine_lc_no",
					width : "70", 
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							<c:if test="${page.fnc.F03242_001 ne 'Y'}">
							alert("권한이 없습니다.");
							return;
							</c:if>
							
							if (confirm("입고센터 확정 취소 처리 하시겠습니까 ?") == false) {
								return false;
							}
							
							var param = {
									machine_lc_no : event.item.machine_lc_no
							}
							
							// 확정취소
							$M.goNextPageAjax(this_page +"/confirm/cancle", $M.toGetParam(param), {method : 'POST'}, 
				   				function(result) {
				   					if(result.success) {
				   						location.reload();
				   					};
				   				}
				   			);
						},
						visibleFunction   :  function(rowIndex, columnIndex, value, item, dataField ) {
							if(item.container_seq != "0") {
							  	return true;
							} else {
							  	return false;
							}	
						},
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '확정취소';
					},
					style : "aui-center",
					cellMerge : true,
					editable : false,
				},
	 			{
	 				headerText : "관리번호",
	 				dataField : "machine_lc_no",
	 				width : "70",
	 				style : "aui-center",
	 				cellMerge : true,
	 				cellColMerge : true,
	 				cellColSpan: 5, // 셀 가로병합
	 				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
	 					return value.substring(4);
	 				},
	 			},
				{ 
					headerText : "입항일(ETA)", 
					dataField : "eta", 
					width : "80", 
					style : "aui-center",
					dataType : "date",  
					formatString : "yy-mm-dd",
					cellMerge : true,
					cellColMerge : true,
					cellColSpan: 3, // 셀 가로병합
				},
				{ 
					headerText : "센터입고일", 
					dataField : "center_in_plan_dt", 
					width : "70", 
					style : "aui-center",
					dataType : "date",  
					formatString : "yy-mm-dd",
					cellMerge : true,
				},
				{ 
					headerText : "컨테이너", 
					dataField : "container_name", 
					width : "120", 
					style : "aui-center",
				},
				{ 
					headerText : "합계", 
					dataField : "total_qty", 
					width : "50", 
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
	 				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
	 					if (item.container_seq == "0") {
	 						return "";
	 					} else {
	 						return value;
	 					}
					},
					expFunction : function(  rowIndex, columnIndex, item, dataField ) {
						var sum = 0;
						for (val in item) {
							if (val.startsWith("mch_")) {
								if (item[val] != "" || item[val] != 0) {
									sum += item[val];
								}
							}
						}
						return sum; 
					}
				},
				{ 
					headerText : "입고센터", 
					dataField : "in_org_name", 
					width : "60", 
					style : "aui-center",
	 				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
	 					if (item.container_seq == "0") {
	 						return "";
	 					} else {
	 						return value;
	 					}
					},
				},
			];
			
			var machineNameList = result.machineNameList;
			// 각 LC에 해당하는 모델 컬럼 열 추가 작업
			var columnObjArr = [];
			
			
			if (machineNameList != undefined) {
				for (var i = 0; i < machineNameList.length; i++) {
					var columnObj = {
							headerText : machineNameList[i].machine_name,
							dataField : machineNameList[i].header_seq,
							width : "10%",
			 				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			 					if (value == "0") {
			 						return "";
			 					} else {
			 						return value;
			 					}
		 					},
					}
					columnObjArr.push(columnObj);
				}
				
				AUIGrid.changeColumnLayout(auiGrid, columnLayout);
				AUIGrid.addColumn(auiGrid, columnObjArr, 7);
			} else {
				columnObjArr = [];				
				AUIGrid.addColumn(auiGrid, columnObjArr, 7);
				AUIGrid.changeColumnLayout(auiGrid, columnLayout);
			}
			
			AUIGrid.setGridData(auiGrid, result.list);
		}
	}
	
	function fnClose() {
		window.close();
	}
	
	</script>
</head>
<body>
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
								<col width="80px">
								<col width="270px">
								<col width="60px">
								<col width="150px">
						</colgroup>
						<tbody>
							<tr>
								<th>센터입고일</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" value="">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="" value="">
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
								<th>메이커</th>
								<td>
									<select id="s_maker_cd" name="s_maker_cd" class="form-control">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['MAKER']}" var="item">
											<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 55px;" onclick="javascript:goSearch();">조회</button></td>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /검색영역 -->			
<!-- 조회결과 -->
			<div class="title-wrap mt10">
				<h4>조회결과</h4>
			</div>
			<div id="auiGrid" style="margin-top: 10px; height: 500px;"></div>
<!-- /조회결과 -->
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
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