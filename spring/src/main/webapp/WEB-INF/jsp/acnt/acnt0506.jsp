<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 카드단말기 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var centerJson = ${orgList}
		var allCenterJson = ${allOrgList}
		var telecomJson = JSON.parse('${codeMapJsonObj['TELECOM']}');
		
		$(document).ready(function() {
			fnInitDate();
			createAUIGrid();
		});
		
		// 21.02.24 이유경님 요청으로 시작일자 2012.12.01로 고정
		function fnInitDate() {
			var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", "20121201");
			
			goSearch();
		}
		
		// 조회
		function goSearch() {
			if($M.getValue("s_start_dt") == "") {
				alert("출고일자를 입력 후 검색해주세요.");
				return false;
			}
			if($M.getValue("s_end_dt") == "") {
				alert("출고일자를 입력 후 검색해주세요.");
				return false;
			}
			var params = {
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_end_dt" : $M.getValue("s_end_dt"),
					"s_center_org_code" : $M.getValue("s_center_org_code"),
					"s_use_yn" : $M.getValue("s_use_yn"),
					"s_sort_key" : "out_dt",
					"s_sort_method" : "desc",
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
		
		// 저장
		function goSave() {
			if(isValid(auiGrid) === false) {
				return false;
			};
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert(msg.alert.data.noChanged);
				return false;
			};
			var frm = fnChangeGridDataToForm(auiGrid);
			if(frm.fix_yn == "null") {
				return false;
			};
			$M.goNextPageAjaxSave(this_page + "/save", frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
						
					};
				}
			);
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_center_org_code", "s_use_yn"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "card_terminal_seq",
				showRowNumColumn: true,
				enableFilter : true,
				editable : true,
				fillColumnSizeMode : false,
				blankToNullOnEditing : true
			};
			var fixList = [
				{fix_yn : "", fix_name : "- 선택 -"},
				{fix_yn : "Y", fix_name : "고정식"},
				{fix_yn : "N", fix_name : "이동식"}
			];
			
			var servYn = "${page.fnc.F00592_001}" == "Y" ? "Y" : "N";
			
			if(servYn == "Y") {
				gridPros.editable = false;
			}
			
			var columnLayout = [
				{
					dataField : "card_terminal_seq", 
					visible : false
				},
				{
					headerText : "출고일", 
					dataField : "out_dt", 
					dataType : "date",   
					width : "75",
					minWidth : "75",
					style : "aui-center",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver : true
					},
					editable : true,
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (servYn != "Y") {
							return "aui-editable"
						};
						return "aui-center";
					},
				},
				{ 
					headerText : "센터", 
					dataField : "center_org_code",
					width : "100",
					minWidth : "100",
					style : "aui-center",
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						editable : true,
						list : centerJson,
						keyField : "org_code",
						valueField  : "org_name"
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
						var retStr = value;
						for(var j = 0; j < allCenterJson.length; j++) {
							if(allCenterJson[j]["org_code"] == value) {
								retStr = allCenterJson[j]["org_name"];
								break;
							}
						}
						return retStr;
					},               
					filter : {
		                  showIcon : true,
						  displayFormatValues : true
		            },
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (servYn != "Y") {
							return "aui-editable"
						};
						return "aui-center";
					},
				},
				{ 
					headerText : "전화번호", 
					dataField : "hp_no",
					width : "120",
					minWidth : "120",
					style : "aui-center",
					editable : true,
					editRenderer : {
						type : "InputEditRenderer",
						onlyNumeric : true,
					},
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     if(String(value).length > 0) {
					         // 전화번호에 대시 붙이는 정규식으로 표현
					         return value.replace(/(^02.{0}|^01.{1}|[0-9]{3})([0-9]+)([0-9]{4})/,"$1-$2-$3"); 
					     }
					     return value; 
					},               
					filter : {
		                  showIcon : true
		            },
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (servYn != "Y") {
							return "aui-editable"
						};
						return "aui-center";
					},
				},
// 				{ 
// 					headerText : "시리얼넘버", 
// 					dataField : "serial_no", 
// 					width : "8%",
// 					style : "aui-center",
// 					editable : true,               
// 					filter : {
// 		                  showIcon : true
// 		            }
// 				},
				{ 
					headerText : "ID", 
					dataField : "term_id", 
					width : "90",
					minWidth : "90",
					style : "aui-center",
					editable : true,               
					filter : {
		                  showIcon : true
		            },
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (servYn != "Y") {
							return "aui-editable"
						};
						return "aui-center";
					},
				},
				{
					headerText : "구입일", 
					dataField : "buy_dt", 
					dataType : "date",   
					width : "75",
					minWidth : "75",
					style : "aui-center",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver : true
					},
					editable : true,               
					filter : {
		                  showIcon : true
		            },
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (servYn != "Y") {
							return "aui-editable"
						};
						return "aui-center";
					},
				},
				{ 
					headerText : "구입금액", 
					dataField : "buy_price",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "90",
					style : "aui-right",
					editable : true,
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (servYn != "Y") {
							return "aui-editable"
						};
						return "aui-right";
					},
				},
				{ 
					headerText : "구입처", 
					dataField : "buy_place", 
					width : "130",
					minWidth : "130",
					style : "aui-center",
					editable : true,
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (servYn != "Y") {
							return "aui-editable"
						};
						return "aui-center";
					},
				},
				{ 
					headerText : "기종", 
					dataField : "term_name", 
					width : "160",
					minWidth : "160",
					style : "aui-center",
					editable : true,               
					filter : {
		                  showIcon : true
		            },
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (servYn != "Y") {
							return "aui-editable"
						};
						return "aui-center";
					},
				},
				{ 
					headerText : "형식", 
					dataField : "fix_yn", 
					width : "50",
					minWidth : "50",
					style : "aui-center",
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						editable : true,
						list : fixList,
						keyField : "fix_yn",
						valueField  : "fix_name",
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
						var retStr = value;
						for(var j = 0; j < fixList.length; j++) {
							if(fixList[j]["fix_yn"] == value) {
								retStr = fixList[j]["fix_name"];
								break;
							} else if(value === null) {
								retStr = "- 선택 -";
								break;
							}
						}
						return retStr;
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (servYn != "Y") {
							return "aui-editable"
						};
						return "aui-center";
					},
				},
				{ 
					headerText : "통신사", 
					dataField : "telecom_cd", 
					width : "80",
					minWidth : "80",
					style : "aui-center",
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						editable : true,
						list : telecomJson,
						keyField : "code_value",
						valueField  : "code_name"
					},               
					filter : {
		                  showIcon : true
		            },
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (servYn != "Y") {
							return "aui-editable"
						};
						return "aui-center";
					},
				},
				{ 
					headerText : "비고", 
					dataField : "remark", 
					width : "180",
					minWidth : "180",
					style : "aui-left",
					editable : true,
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (servYn != "Y") {
							return "aui-editable"
						};
						return "aui-left";
					},
				},
				{ 
					headerText : "사용여부", 
					dataField : "use_yn", 
					width : "70",
					minWidth : "70",
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
					width : "50",
					minWidth : "50",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item.card_terminal_seq);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);		
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
							}
						},
						visibleFunction : function(rowIndex, columnIndex, value, item, dataField ) {
							// 삭제버튼은 행 추가시에만 보이게 함
							if(AUIGrid.isAddedById("#auiGrid", item.card_terminal_seq)) {
							  	return true;
							}
							else {
							  	return false;
							}	
						}
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
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
		}
		
		//그리드 행추가
		function fnAdd() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "out_dt");
			fnSetCellFocus(auiGrid, colIndex, "out_dt");
			var row = new Object();
			if(isValid()) {
				row.out_dt = '';
				row.center_org_code = '';
				row.hp_no = '';
				row.serial_no = '';
				row.serial_no2 = '';
				row.term_id = '';
				row.buy_dt = '';
				row.buy_price = '';
				row.buy_place = '';
				row.term_name = '';
				row.fix_yn = '';
				row.telecom_cd = '';
				row.remark = '';
				row.use_yn = 'Y';
				AUIGrid.addRow(auiGrid, row, "last");
			}
		}

		// 그리드 빈값 체크
		function isValid() {
			return AUIGrid.validateGridData(auiGrid, ["out_dt", "center_org_code", "term_id"], "필수 항목는 반드시 값을 입력해야 합니다.");
		}
		
		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
			  };
		  	fnExportExcel(auiGrid, "카드단말기관리", exportProps);
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
								<col width="65px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">출고일자</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd"  value=" alt="출고 시작일">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd"  value="${inputParam.s_end_dt}" alt="출고 완료일">
												</div>
											</div>
										</div>
									</td>
									<th>센터</th>
									<td>
										<c:choose>
											<c:when test="${page.fnc.F00592_002 eq 'Y'}">
												<select class="form-control" id="s_center_org_code" name="s_center_org_code">
													<option value="">- 전체 -</option>
													<c:forEach var="item" items="${orgCenterList}">
<%-- 														<option value="${item.org_code}">${item.org_name}</option> --%>
														<option value="${item.org_code}" ${item.org_code == inputParam.s_center_org_code ? 'selected="selected"' : ''}>${item.org_name}</option>
													</c:forEach>
												</select>
											</c:when>
											<c:when test="${SecureUser.org_type ne 'BASE'}">
												<div class="col width100px" style="padding-right: 0;">
													<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly">
													<input type="hidden" value="${SecureUser.org_code}" id="s_center_org_code" name="s_center_org_code" readonly="readonly">
												</div> 
											</c:when>
										</c:choose>
									</td>
									<th>사용구분</th>
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
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
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
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>	
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>