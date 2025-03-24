<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품그룹코드 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var partSummaryList = JSON.parse('${codeMapJsonObj['PART_GROUP_SUMMARY']}');
		partSummaryList.unshift({code_value : "", code_name : ""});

		<%-- 여기에 스크립트 넣어주세요. --%>
		$(document).ready(function() {
			createAUIGrid();
			// goSearch();
		});

		function goSetting() {
			var param = {
				group_code : "PART_GROUP_SUMMARY",
				all_yn : "Y"
			}
			openGroupCodeDetailPanel($M.toGetParam(param));
		}
		
		//메인그리드
		function createAUIGrid() {
			var gridPros = {
				editable : true,
				// rowIdField 설정
				rowIdField : "_$uid", 
				/* rowIdTrustMode : true, */
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				enableSorting : true,
				showStateColumn : true,
			};
			var columnLayout = [
				{
					dataField : "group_code",
					visible : false
				},
				{
					headerText : "부품분류요약코드",
					dataField : "code_v1",
					width : "10%",
					editable : true,
					style : "aui-editable",
					editRenderer : {
						type : "DropDownListRenderer",
						list: partSummaryList,
						keyField: "code_value",
						valueField : "code_name"
					},
					labelFunction: function (rowIndex, columnIndex, value) {
						for (var i = 0; i < partSummaryList.length; i++) {
							if (value == partSummaryList[i].code_value) {
								return partSummaryList[i].code_name;
							}
						}
						return value;
					}
				},
				{ 
					headerText : "분류코드", 
					dataField : "code", 
					width : "13%", 
					style : "aui-center",
					editable : true,
					required : true,
					editRenderer : {
						type : "InputEditRenderer",
						auiGrid : "#auiGrid",
						maxlength : 30,
						// 에디팅 유효성 검사
						validator : AUIGrid.commonValidator
					}
				},
				{ 
					headerText : "분류명1", 
					dataField : "code_name", 
					width : "30%", 
					style : "aui-left aui-editable",
					editable : true,
					required : true,
					editRenderer : {
					      type : "InputEditRenderer",
					      maxlength : 200,
					      // 에디팅 유효성 검사
					      validator : AUIGrid.commonValidator
					}
				},
				{ 
					headerText : "분류명2", 
					dataField : "code_desc", 
					style : "aui-left aui-editable",
					editable : true,
					required : true,
					editRenderer : {
					      type : "InputEditRenderer",
					      // 에디팅 유효성 검사
					      maxlength : 200,
					      validator : AUIGrid.commonValidator
					}
				},
				{ 
					headerText : "정렬순서", 
					dataField : "sort_no", 
					width : "10%", 
					dataType : "numeric",
					style : "aui-right aui-editable",
					editable : true,
					editRenderer : {
					    type : "InputEditRenderer",
					    onlyNumeric : true
					}
				},
				{ 
					headerText : "사용여부", 
					dataField : "use_yn", 
					width : "8%", 
					style : "aui-center",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					}
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "8%",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);		
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
							}
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
				if(event.dataField == "code") {
					// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
					if(AUIGrid.isAddedById(event.pid, event.item._$uid)) {
						return true;
					} else {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "조회된 분류코드는 수정할 수 없습니다.");
						}, 1);
						return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
					}
				}
				return true; // 다른 필드들은 편집 허용
			});
	    }
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_code", "s_code_name", "s_code_desc", "s_use_yn"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		function goSearch() { 
			var param = {
					"s_code" : $M.getValue("s_code"),
					"s_code_name" : $M.getValue("s_code_name"),
					"s_code_desc" : $M.getValue("s_code_desc"),
					"s_use_yn" : $M.getValue("s_use_yn"),
					"s_sort_key" : "s_code",
					"s_sort_method" : "desc"
			};
			$M.goNextPageAjax(this_page + "/PART_GROUP/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			if (fnCheckGridEmpty(auiGrid) === false){
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			}
			goCheckDuplicate();
		}
		
		// 중복체크
		function goCheckDuplicate() {
			var arr1 = AUIGrid.getAddedRowItems(auiGrid);
			if (arr1.length > 0) {
				// 수정된 row 체크하면 무조건 중복체크 에러 나서 주석처리함
				/* var arr2 = AUIGrid.getEditedRowItems(auiGrid);
				Array.prototype.push.apply(arr1,arr2);  */
				var param = {
						"group_code_str" : $M.getArrStr(arr1, {key : "group_code"}),
						"code_str" : $M.getArrStr(arr1, {key : "code"})
				};
				$M.goNextPageAjax("/comm/comm9901", $M.toGetParam(param), '', 
					function(result) {
						if(result.success) {
							goSavePartGroup();
						};
					}
				);
			} else {
				goSavePartGroup();
			};
		}
		
		function goSavePartGroup() {
			var frm = fnChangeGridDataToForm(auiGrid);
			$M.goNextPageAjaxSave(this_page + "/PART_GROUP"+"/save", frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
					};
				}
			);
		}
	   
		// 행 추가, 삽입
		function fnAdd() {
	    	if(fnCheckGridEmpty()) {
	    		var item = new Object();
	    		item.group_code = "PART_GROUP";
	    		item.code = "";
	    		item.code_name = "";
	    		item.code_desc = "";
	    		item.sort_no = 0;
	    		item.use_yn = "N";
				AUIGrid.addRow(auiGrid, item, 'last');
	    	}
		}
		
		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			//return AUIGrid.validateGridData(auiGrid, ["code", "code_name", "code_desc"], "필수 항목은 반드시 값을 입력해야합니다.");
			return AUIGrid.validation(auiGrid);
		}
		
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
			         // 제외항목
			         exceptColumnFields : ["removeBtn"]
			  };
			  fnExportExcel(auiGrid, "부품그룹코드", exportProps);
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
	<!-- 기본 -->					
				<div class="search-wrap">
					<table class="table">
						<colgroup>
							<col width="100px">
							<col width="130px">
							<col width="100px">
							<col width="130px">
							<col width="100px">
							<col width="130px">
							<col width="70px">
							<col width="70px">
						</colgroup>
						<tbody>
							<tr>
								<th>분류코드</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control" id="s_code" name="s_code">
									</div>
								</td>
								<th>분류명1</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control" id="s_code_name" name="s_code_name">
									</div>
								</td>
								<th>분류명2</th>
								<td>
									<input type="text" class="form-control" id="s_code_desc" name="s_code_desc">
								</td>
								<th>사용여부</th>
								<td>
									<select class="form-control" id="s_use_yn" name="s_use_yn">
										<option value="">- 전체 -</option>
										<option value="Y">사용</option>
										<option value="N">미사용</option>
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
						<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div  id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>						
					<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
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