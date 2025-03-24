<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 법인카드관리 > null > null
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
			
			// 관리부이거나, 최승희대리일경우를 제외하면 구분선택 못함. 해당부서와, 본인것만 조회가능.
			if (("${page.fnc.F00594_001}" == "Y") == false) {
				$("#s_org_code").prop("disabled", true);
			}
		});
		
		// 법인카드 조회
		function goSearch() {
			var params = {
					"s_org_code" : $M.getValue("s_org_code"),
					"s_kor_name" : $M.getValue("s_kor_name"),
					"s_card_code" : $M.getValue("s_card_code"),
					"s_card_no" : $M.getValue("s_card_no"),
					"s_hipass_yn" : $M.getValue("s_hipass_yn"),
					"s_card_type_dm" : $M.getValue("s_card_type_dm"),
					"s_use_yn" : $M.getValue("s_use_yn"),
				};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), { method : 'get'},
				function(result) {
					if(result.success) { 
						AUIGrid.setGridData(auiGrid, result.list);
						AUIGrid.expandAll(auiGrid);
						$("#total_cnt").html(result.total_cnt);
					}
				}
			);
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_kor_name", "s_card_code", "s_card_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 법인카드 리스트 그리드
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
// 				rowIdField : "card_code",
				rowIdTrustMode : true,
				showRowNumColumn: true,
// 				enableFilter : true,
				editable : true,
				fillColumnSizeMode : false,
				blankToNullOnEditing : true,
				showStateColumn : false,
			};
			var hipassYnList = [
				{hipass_yn : "", hipass_yn_name : "- 선택 -"},
				{hipass_yn : "Y", hipass_yn_name : "하이패스"},
				{hipass_yn : "N", hipass_yn_name : "일반"}
			];
			var cardTypeList = [
				{card_type_dm : "", card_type_dm_name : "- 선택 -"},
				{card_type_dm : "D", card_type_dm_name : "공용"},
				{card_type_dm : "M", card_type_dm_name : "지정"}
			];
			var columnLayout = [
				{
					headerText : "관리코드", 
					dataField : "card_code", 
					width : "75",
					minWidth : "75",
					style : "aui-center",
// 					editable : false
				},
				{
					headerText : "카드번호", 
					dataField : "card_no", 
					width : "160",
					minWidth : "160",
					style : "aui-center aui-editable",
					editable : true,
					editRenderer : {
						type : "InputEditRenderer",
						onlyNumeric : true,
					},
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return $M.creditCardFormat(value); 
					}
				},
				{ 
					headerText : "카드명", 
					dataField : "card_name", 
					width : "180",
					minWidth : "180",
					style : "aui-left aui-editable",
					editable : true
				},
				{
					headerText : "유효기간",
					dataField : "expiration_mon",
					dataType : "date",
					width : "110",
					minWidth : "110",
					style : "aui-center aui-editable",
					dateInputFormat : "yyyymm",
					formatString : "yyyy-mm",
					editRenderer : {
						type : "CalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymm",
						onlyCalendar : true, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 6,
						showEditorBtnOver : true,
						onlyMonthMode : true
					},
					editable : true,
				},
				{
					headerText : "카드한도",
					dataField : "limit_amt",
					width : "110",
					minWidth : "110",
					style : "aui-right aui-editable",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{ 
					headerText : "카드종류", 
					dataField : "hipass_yn",
					width : "80",
					minWidth : "80",
					style : "aui-center aui-editable",
// 					editable : true
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : true,
						showEditorBtnOver : true,
						editable : true,
						list : hipassYnList,
						keyField : "hipass_yn",
						valueField  : "hipass_yn_name",
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
						var retStr = value;
						for(var j = 0; j < hipassYnList.length; j++) {
							if(hipassYnList[j]["hipass_yn"] == value) {
								retStr = hipassYnList[j]["hipass_yn_name"];
								break;
							} else if(value === null) {
								retStr = "- 선택 -";
								break;
							}
						}
						return retStr;
					}
				},
// 				{ 
// 					dataField : "hipass_yn",
// 					visible : false
// 				},
				{ 
					headerText : "카드구분", 
					dataField : "card_type_dm", 
					width : "60",
					minWidth : "60",
					style : "aui-center aui-editable",
// 					required : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : true,
						showEditorBtnOver : true,
						editable : true,
						list : cardTypeList,
						keyField : "card_type_dm",
						valueField  : "card_type_dm_name",
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
						var retStr = value;
						for(var j = 0; j < cardTypeList.length; j++) {
							if(cardTypeList[j]["card_type_dm"] == value) {
								retStr = cardTypeList[j]["card_type_dm_name"];
								break;
							} else if(value === null) {
								retStr = "- 선택 -";
								break;
							}
						}
						return retStr;
					}
				},
// 				{ 
// 					dataField : "card_type_dm", 
// 					visible : false
// 				},
				{ 
					headerText : "부서", 
					dataField : "org_name", 
					width : "80",
					minWidth : "80",
					style : "aui-center",
					editable : false,
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(item.card_type_dm == "D") {
							return "aui-editable";
						} else {
							return "aui-center";
						}
					},
				},
				{ 
					dataField : "org_code", 
					visible : false
				},
				{ 
					headerText : "사용자명", 
					dataField : "mem_name", 
					width : "80",
					minWidth : "80",
					style : "aui-center",
					editable : false,
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(item.card_type_dm == "M") {
							return "aui-editable";
						} else {
							return "aui-center";
						}
					}
				},
				/*{
					headerText : "계정아이디", 
					dataField : "web_id", 
					width : "110",
					minWidth : "110",
					style : "aui-center",
					editable : false
				},
				*/
				// 저장시 mem_no가 로그인 사용자 것으로 세팅되어 추가. 2022-12-27 김상덕
				{
					dataField : "mem_no",
					visible : false
				},
				{ 
					headerText : "비고", 
					dataField : "remark", 
					width : "370",
					minWidth : "370",
					style : "aui-left aui-editable",
					editable : true
				},
				{ 
					headerText : "사용여부", 
					dataField : "use_yn", 
					width : "65",
					minWidth : "65",
					style : "aui-center aui-editable",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					}
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				$M.setValue("clickedRowIndex", event.rowIndex);
				var card_type_dm_name = event.item["card_type_dm_name"];
				
				// "카드구분" 선택 안하고 "부서" 또는 "사용자" 셀 선택시
				if((event.dataField == "org_name" || event.dataField == "mem_name") && (event.item["card_type_dm"] != "M" && event.item["card_type_dm"] != "D") ) {
					setTimeout(function() {
						AUIGrid.showToastMessage(auiGrid, event.rowIndex, AUIGrid.getColumnIndexByDataField(auiGrid, "card_type_dm"), "카드구분을 선택해주세요.");
					});
					return false;
				}
				// 카드구분 "공용" 일때만 부서조회
				if(event.dataField == "org_name") {
					if(event.item["card_type_dm"] == "D") {
						openOrgMapPanel("setOrgCodeInfo");
					} else {
						return false;
					}
				}
				// 카드구분 "지정" 일때만 직원조회
				if(event.dataField == "mem_name") {
					if(event.item["card_type_dm"] == "M") {
						var param = {
								"s_org_code" : event.item["org_code"]
						};
						openSearchMemberPanel("fnSetMemberInfo", $M.toGetParam(param));
					} else {
						return false;
					}
				}
				
				// 체크박스
				if(String(this.tagName).toUpperCase() == "INPUT") return;
				if(event.dataField == "use_yn") {
					if(event.value == "Y") {
						AUIGrid.setCellValue(event.pid, event.rowIndex, "use_yn", "N");
					} 
					if(event.value == "N") {
						AUIGrid.setCellValue(event.pid, event.rowIndex, "use_yn", "Y");
					}
				} 
			});
			
			// 행 추가 시 셀렉션을 카드코드로 이동시킴
			AUIGrid.bind(auiGrid, "addRowFinish", function(event) {
				var selectionIdxes = AUIGrid.getSelectedIndex(event.pid);
				AUIGrid.setSelectionByIndex(event.pid, selectionIdxes[0], 0);
			});
			
			// 에디팅 시작 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
				if(event.dataField == "card_code") {
					// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
					if(AUIGrid.isAddedById(event.pid, event.item._$uid)) {
						return true;
					} else {
						return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
					}
				}
				return true; // 다른 필드들은 편집 허용
			});
		}
			
		// "부서조회"팝업에서 선택한 정보 입력
		function setOrgCodeInfo(data) {
			var rowIndex = $M.getValue("clickedRowIndex");
			AUIGrid.setCellValue(auiGrid, rowIndex, "org_name", data.org_name);
			AUIGrid.setCellValue(auiGrid, rowIndex, "org_code", data.org_code);
			
			// 사용자정보 clear
			AUIGrid.setCellValue(auiGrid, rowIndex, "mem_name", "");
			AUIGrid.setCellValue(auiGrid, rowIndex, "web_id", "");
			AUIGrid.setCellValue(auiGrid, rowIndex, "mem_no", "");
		}
		
		// "직원조회"팝업에서 선택한 정보 입력
		function fnSetMemberInfo(data) {
			var rowIndex = $M.getValue("clickedRowIndex");
			AUIGrid.setCellValue(auiGrid, rowIndex, "mem_name", data.mem_name);
			AUIGrid.setCellValue(auiGrid, rowIndex, "web_id", data.web_id);
			AUIGrid.setCellValue(auiGrid, rowIndex, "mem_no", data.mem_no);
			
			// 부서정보 clear
			AUIGrid.setCellValue(auiGrid, rowIndex, "org_name", "");
			AUIGrid.setCellValue(auiGrid, rowIndex, "org_code", "");
		}
	
		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
			  };
		  	fnExportExcel(auiGrid, "법인카드관리", exportProps);
		}
		
		//그리드 행추가
		function fnAdd() {
			if(isValid()) {
				var row = new Object();
				row.card_code = '';
				row.card_no = '';
				row.card_name = '';
				row.hipass_yn = '';
				row.card_type_dm = '';
				row.use_yn = 'Y';
				row.remark = '';
				AUIGrid.addRow(auiGrid, row, "first");
			}
		}
		
		// 저장
		function goSave() {
			var addData = AUIGrid.getAddedRowItems(auiGrid); // 변경내역
			var data = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
			
			data = data.concat(addData);
			
			console.log(data);
			
			if (data.length == 0){
				alert("저장 할 데이터가 없습니다.");
				return false;
			};
			
			for (var i = 0; i < data.length; i++) {
				var rowIdField = AUIGrid.getProp(auiGrid, "rowIdField"); // 그리드 인덱스 구하기
				var rowIndex = AUIGrid.rowIdToIndex(auiGrid, data[i][rowIdField]); // 그리드 인덱스 구하기		
				
				if (data[i].card_code == null || data[i].card_code == "") {
					AUIGrid.showToastMessage(auiGrid, rowIndex, AUIGrid.getColumnIndexByDataField(auiGrid, "card_code"), "관리코드 입력해주세요.");
					return;
				}
				
				if (data[i].card_no == null || data[i].card_no == "") {
					AUIGrid.showToastMessage(auiGrid, rowIndex, AUIGrid.getColumnIndexByDataField(auiGrid, "card_no"), "카드번호 입력해주세요.");
					return;
				}
				
				if (data[i].card_type_dm == null || data[i].card_type_dm == "") {
					AUIGrid.showToastMessage(auiGrid, rowIndex, AUIGrid.getColumnIndexByDataField(auiGrid, "card_type_dm"), "카드구분을 입력해주세요.");
					return;
				}
				
				if (data[i].card_type_dm == "D" || data[i].card_type_dm == "") {
					if (data[i].org_code == "") {
						AUIGrid.showToastMessage(auiGrid, rowIndex, AUIGrid.getColumnIndexByDataField(auiGrid, "org_name"), "부서를 입력해주세요.");
						return;
					}
				}
				
				if (data[i].card_type_dm == "M" || data[i].card_type_dm == "") {
					if (data[i].mem_no == "") {
						AUIGrid.showToastMessage(auiGrid, rowIndex, AUIGrid.getColumnIndexByDataField(auiGrid, "mem_name"), "사용자를 입력해주세요.");
						return;
					}
				}
			}
			
			var frm = fnChangeGridDataToForm(auiGrid);

			$M.goNextPageAjaxSave(this_page + "/save", frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}
		
		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["org_name"], "부서");
		}
		
		// 그리드 빈값 체크
		function fnCheckGridEmpty2() {
			return AUIGrid.validateGridData(auiGrid, ["mem_name"], "사용자명");
		}
		
		// 그리드 빈값 체크
		function isValid() {
			var msg = "필수 항목은 반드시 값을 입력해야 합니다.";
			// 기본 필수 체크
			var reqField = ["card_code", "card_no", "card_name", "hipass_yn", "card_type_dm", "use_yn"];
			var isCommReqValid = AUIGrid.validateGridData(auiGrid, reqField, msg);
			if(!isCommReqValid) {
				return false;
			}
			// 공용카드일경우 부서 필수 체크
			var dTypeData = AUIGrid.getRowsByValue(auiGrid, "card_type_dm", ["D"]);
			for(var i in dTypeData) {
				if((dTypeData[i].org_name == undefined || dTypeData[i].org_name == "" || dTypeData[i].org_name == null)) {
					AUIGrid.showToastMessage(auiGrid, AUIGrid.rowIdToIndex(auiGrid, dTypeData[i]._$uid), AUIGrid.getColumnIndexByDataField(auiGrid, "org_name"), "부서를 입력해주세요.");
					return false;
				}
			}
			// 지정 카드일경우 사용자 필수 체크
			var mTypeData = AUIGrid.getRowsByValue(auiGrid, "card_type_dm", ["M"]);
			for(var i in mTypeData) {
				if((mTypeData[i].mem_name == undefined || mTypeData[i].mem_name == "" || mTypeData[i].mem_name == null)) {
					AUIGrid.showToastMessage(auiGrid, AUIGrid.rowIdToIndex(auiGrid, mTypeData[i]._$uid), AUIGrid.getColumnIndexByDataField(auiGrid, "mem_name"), "사용자를 입력해주세요.");
					return false;
				}
			}
			return true;
		}
	</script>
</head>
<body>
<input type="hidden" id="clickedRowIndex" name="clickedRowIndex">
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
							<col width="40px">
							<col width="90px">	
							<col width="55px">
							<col width="90px">
							<col width="55px">
							<col width="90px">	
							<col width="55px">
							<col width="140px">	
							<col width="55px">
							<col width="80px">	
							<col width="55px">
							<col width="80px">
							<col width="55px">
							<col width="80px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>부서</th>
								<td>
									<select class="form-control" id="s_org_code" name="s_org_code">
										<option value="">전체</option>
										<c:forEach items="${orgList}" var="item">
											<option value="${item.org_code}" ${item.org_code == inputParam.s_org_code ? 'selected="selected"' : ''}>${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>사용자명</th>
								<td>
									<input type="text" class="form-control" id="s_kor_name" name="s_kor_name">
								</td>
								<th>관리코드</th>
								<td>
									<input type="text" class="form-control" id="s_card_code" name="s_card_code">
								</td>
								<th>카드번호</th>
								<td>
									<input type="text" class="form-control" id="s_card_no" name="s_card_no">
								</td>
								<th>카드종류</th>
								<td>
									<select class="form-control" id="s_hipass_yn" name="s_hipass_yn">
										<option value="">전체</option>
										<option value="N">일반</option>
										<option value="Y">하이패스</option>
									</select>
								</td>
								<th>카드구분</th>
								<td>
									<select class="form-control" id="s_card_type_dm" name="s_card_type_dm">
										<option value="">전체</option>
										<option value="D">공용</option>
										<option value="M">지정</option>
									</select>
								</td>
								<th>사용여부</th>
								<td>
									<select class="form-control"  id="s_use_yn" name="s_use_yn">
										<option value="Y">사용</option>
										<option value="N">미사용</option>
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