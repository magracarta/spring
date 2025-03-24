<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 근무관리 > 센터별비상대기표 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-03-17 14:42:21
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		var auiGrid;
		var footerLayout = [];
		var centerCodeArr = [];
		var memListByCenter = ${memList}
		var memList = ${allMemList}
		var modCols = []; // 수정한 컬럼
		var thisWeekWorker = {}; // 이번주 비상근무
		var today = "";
		var todayWeekDt = "";
		var isLoad = false;
		
		$(document).ready(function() {
			today = getToday();
			createAUIGrid(); // 메인 그리드
			goSearch();
		});
		
		function getToday(){
		    var date = new Date();
		    var year = date.getFullYear();
		    var month = ("0" + (1 + date.getMonth())).slice(-2);
		    var day = ("0" + date.getDate()).slice(-2);
		    return year + month + day;
		}
		
		function createAUIGrid() {
			var gridPros = {
				editable : true,
				// rowIdField 설정
				rowIdField : "_$uid", 
				/* rowIdTrustMode : true, */
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				enableSorting : false,
				showStateColumn : true,
				enableCellMerge : true,
				rowSelectionWidthMerge : true,
				// 푸터 보이게 설정
				showFooter : true,
				// 푸터를 상단에 출력시킴(기본값: "bottom")
				footerPosition : "top",
			};
			var columnLayout = [
				{
					dataField : "week_st_dt",
					visible : false
				},
				{ 
					headerText : "년월", 
					dataField : "week_mon", 
					style : "aui-center",
					dataType : "date",  
					formatString : "yyyy-mm",
					width : "75",
					minWidth : "75",
					editable : false,
					cellMerge : true
				},
				{ 
					headerText : "주차", 
					dataField : "week_cnt", 
					style : "aui-center",
					width : "60",
					minWidth : "60",
					editable : false,
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) { 
						return value+"주차";
					}
				},
				{ 
					headerText : "기간", 
					dataField : "week_range_dt", 
					style : "aui-center",
					width : "100",
					minWidth : "100",
					editable : false,
				}
			];

			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

			AUIGrid.bind(auiGrid, "cellEditEnd", function(event) {
				if (event.oldValue != event.value && !modCols.includes(event.value)) {
					modCols.push(event.dataField);
				}
			});

			// 그리드 갱신
			footerLayout = [
				{
					labelText : "이번주 비상 근무",
					positionField : "week_mon",
					style : "aui-right aui-calendar-today-bg",
					colSpan : 2
				}
			]

			AUIGrid.setGridData(auiGrid, []);
			var list = ${centers}
			for (var i = 0; i < list.length; ++i) {
				var result = list[i];
				var orgCode = result.org_code;
				var columnObj = {
					headerText : result.org_name.substring(0, 2),
					dataField : result.org_code,
					style : "aui-center",
					width : "5%",
					editable : true,
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
						var retStr = value;
						for(var j = 0; j < memList.length; j++) {
							if(memList[j]["mem_no"] == value) {
								retStr = memList[j]["mem_name"];
								if (memList[j]["work_status_cd"] == "04") {
									retStr = retStr+"(퇴직)";
								}
								break;
							} else if (value != "") {
								// 삭제된 사용자(근무대기표에 등록된 회원이 회원테이블에 없는 경우)
								retStr = "";
							}
						}
						return retStr;
					},
					editRenderer : {
						type : "DropDownListRenderer",
						list : memListByCenter[orgCode] != null ? memListByCenter[orgCode].sort(compare) : [],
						keyField : "mem_no",
						showEditorBtn : false,
						valueField  : "mem_name",
					}
				}

				centerCodeArr.push(list[i].org_code);
				AUIGrid.addColumn(auiGrid, columnObj, 'last');
			}

			$M.setValue("s_year", "${inputParam.s_current_year}");
		}

		function compare( a, b ) {
			if ( a.mem_name < b.mem_name ) {
				return -1;
			}
			if ( a.mem_name > b.mem_name ) {
				return 1;
			}
			return 0;
		}
		
		function goSearch() {
			modCols = [];
			var mon = $M.getValue("s_mon");
			if (mon.length == 1){
				mon = "0"+mon;
			}
			var param = {
					"s_center_str" : $M.getArrStr(centerCodeArr),
					"s_year_mon" : $M.getValue("s_year")+mon,
					"s_sort_key" : "week_mon, week_cnt",
					"s_sort_method" : "asc"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						var list = result.list;
						for (var i = 0; i < list.length; ++i) {
							for (var property in list[i]) {
								if (list[i].hasOwnProperty(property) && property.toString().indexOf('mem_no', property.toString().length - property.toString().length) !== -1) {
									list[i][property.substring(1,5)] = list[i][property];
								}	
							}
							if (list[i].week_st_dt <= today && list[i].week_ed_dt >= today) {
								thisWeekWorker = list[i];
								todayWeekDt = list[i].week_st_dt;
							} else {
								continue;
							}
						}
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
						
						if (jQuery.isEmptyObject(thisWeekWorker) == false) {
							var label = {
								labelText : thisWeekWorker.week_range_dt,
								positionField : "week_range_dt",
								style : "aui-center aui-part-col-style",
							}
							footerLayout.push(label);
							for (var property in thisWeekWorker) {
								if (thisWeekWorker.hasOwnProperty(property) && property.toString().indexOf('mem_name', property.toString().length - property.toString().length) !== -1) {
									var label = {
										labelText : thisWeekWorker[property],
										positionField : property.substring(1,5),
										style : "aui-center aui-calendar-today-bg",
									}
									footerLayout.push(label);
								}	
							}
							AUIGrid.setFooter(auiGrid, footerLayout);
							AUIGrid.resize(auiGrid);
						}

						// [3차 - 13306] 서비스
						// 드롭다운 클릭 이벤트 제어
						AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
							var clickOrgCode = event.dataField; // 클릭된 행 orgCode
							var clickStDt = event.item.week_st_dt; // 클릭된 행 시작 주차
							var toDayStDt = thisWeekWorker.week_st_dt; // 이번주 시작 주차
							var currOrgCode = '${SecureUser.org_code}'; // 로그인 된 사용자 orgCode
							var currMemNo = '${SecureUser.mem_no}';

							// 0. 최승희 대리, 김상덕
							if('${page.fnc.F00495_001}' == 'Y') {
								return true;
							}

							// - 1. 이전 날짜에 대해선 수정 불가
							if(clickStDt < toDayStDt) {
								alert("기간이 지난 주차는 수정할 수 없습니다.");
								return false
							}

							// - 2. 로그인된 사용자는 다른 센터 수정 불가
							if(currOrgCode != clickOrgCode) {
								alert("다른 센터는 수정할 수 없습니다.");
								return false;
							}
						});
					};
				}
			);
		}
		
		function findValueByPrefix(object, prefix) {
			for (var property in object) {
				if (object.hasOwnProperty(property) && property.toString().startsWith(prefix)) {
					object[property.substring(1,5)]
				}	
			}
		}
	
		// 셀렉트박스에서 변경 시
		function yearMonChange() {
			var sYear = $M.getValue("s_year");
			var sMon = $M.getValue("s_mon");
			if(sMon.length == 1) {
				sMon = "0" + sMon;
			}
			var sYearMon = sYear + sMon;
			$M.setValue("s_year_mon", $M.dateFormat($M.toDate(sYearMon), 'yyyyMM'));
			//goSearch();
		}
		
		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			// 한 로우 마다 센터코드에 해당하는 리스트를 만들어서  week_st_dt, center_code, mem_no, use_yn을 만들기
			var array = AUIGrid.getEditedRowItems(auiGrid);
			var weekStDtArr = [], codeArr = [], memNoArr = [], useYnArr = [], cmd = [];
			for (var i = 0; i < array.length; ++i) {
				for (var prop in array[i]) {
					if (array[i][prop] != "" && modCols.includes(prop)) {
					/* if (array[i][prop] != "" && centerCodeArr.includes(prop)) { 모든 센터 목록 */
						weekStDtArr.push(array[i].week_st_dt);
						codeArr.push(prop);
						memNoArr.push(array[i][prop]);
						useYnArr.push("Y");
						cmd.push("U");
					}
				}
			}
			var param = {
				work_dt_str : $M.getArrStr(weekStDtArr),
				center_org_code_str : $M.getArrStr(codeArr),
				mem_no_str : $M.getArrStr(memNoArr),
				use_yn_str : $M.getArrStr(useYnArr)
			}
			$M.goNextPageAjaxSave(this_page, $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						AUIGrid.resetUpdatedItems(auiGrid);
						modCols = [];
						if (weekStDtArr.includes(todayWeekDt)) {
							goSearch();
						}
					};
				}
			);
		}
		
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
			  };
			  fnExportExcel(auiGrid, "센터별비상대기표", exportProps);
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
						<table class="table table-fixed">
							<colgroup>
								<col width="65px">
								<col width="150px">									
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>조회년월</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-7">
												<select class="form-control" id="s_year" name="s_year">
													<c:forEach var="i" begin="${inputParam.s_current_year-5}" end="${inputParam.s_current_year+5}" step="1">
														<option value="${i}" <c:if test="${i==inputParam.s_year}">selected</c:if>>${i}년</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-5">
												<select class="form-control" id="s_mon" name="s_mon">
													<option value="">- 전체 -</option>
													<c:forEach var="i" begin="1" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_mon}">selected</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
										</div>
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
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>			
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>