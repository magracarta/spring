<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > KPI집계 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var partNoNames = {};
		var monArr = ["12", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11"];
		var monthArr = [];
		var searchType = "";
		var partGroupCd = JSON.parse('${codeMapJsonObj['PART_GROUP']}');
	
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();
			setBranchColumnProp();
		});
		
		function fnChangeType() {
			$(".searchType").toggleClass("dpn");
		}
		
		// 비교군 팝업
		function goControlGroupPopup() {
			var param = {
				s_year : $M.getValue("s_year"),
				s_part_no_str 	: $M.getValue("part_no"),
				s_part_group_cd_str 	: $M.getValue("part_group_cd"),
			}
			
			var type = $M.getValue("s_type");
			param["s_type"] = type;
			if (type == "P") {
				if (param.s_part_no_str == "") {
					alert("부품을 선택해주세요.");
					return false;
				}
			} else {
				if (param.s_part_group_cd_str == "") {
					alert("부품 그룹을 선택해주세요.");
					return false;
				}
			}
			
			var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=700, left=0, top=0";
			$M.goNextPage("/part/part0607p02", $M.toGetParam(param), {popupStatus : popupOption});
		}
		
		// 부품조회 창에서 받아온 값
		function setPartInfo(rows) {
			for (var i = 0; i < rows.length; ++i) {
				if (Object.keys(partNoNames).length == 5) {
					break;
				}
				partNoNames[rows[i].part_no] = rows[i].part_name;
			}
			setFileInfo(partNoNames);
		}
		
		//그리드 스타일을 동적으로 바꾸기
	 	function myCellStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField) {
           	if (item.col == "매출") {
             	return "aui-popup";
            } 
        };
		
		function setFileInfo(result) {
			$("#partNos").html("");
			for (var partNo in result) {
		        if (result.hasOwnProperty(partNo)) {
		        	var str = ""; 
					str += "<li class='inline'>";
					// str += "<a style='color:blue'>" + result[partNo] + "</a>&nbsp;";
					str += "<a style='color:blue'>" + partNo + "</a>&nbsp;";
					str += "<input type='checkbox' checked style='display:none' name='part_no' value=\""+ partNo + "\"/>";
					str += "<button type='button' class='btn-default' onclick='fnRemovePart(\""+ partNo + "\")'><i class='material-iconsclose font-18 text-default'></i></button>";
					str += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
					str += "</li>";
					$("#partNos").append(str);
		        }
		    }
		}
		
		function fnRemovePart(partNo) {
			delete partNoNames[partNo]; 
			setFileInfo(partNoNames);
		}
		
		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn : false,
				rowIdField : "_$uid",
	            // 그룹핑 후 셀 병합 실행
	            enableCellMerge : true,
	            enableSorting  : false,
	            wordWrap : true
	            
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "부품",
				    dataField: "part_no",
				    
					width : "90",
					minWidth : "90",
					cellMerge : true,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						if (searchType == "G") {
							var retStr = value;
							for(var j = 0; j < partGroupCd.length; j++) {
								if(partGroupCd[j]["code_value"] == value) {
									retStr ="("+value+") "+partGroupCd[j]["code_name"];
									break;
								}
							}
							return retStr;
						} else {
							return value;
						}
					},
					colSpan : 2
				},
				{
				    dataField: "col",
					width : "95",
					minWidth : "95"
				},
			];
			
			for (var i = 0; i < 12; ++i) {
				var mon = "month_"+$M.lpad(i+1, 2, '0');
				columnLayout.push(
						{
							dataField : mon,
							style : "aui-right",
							styleFunction: myCellStyleFunction,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								return value == null || value == "0" ? "" : $M.setComma(value)
							},
						}
				);
				monthArr.push(mon);
			}
			
			// 푸터레이아웃
			var footerColumnLayout = [];
	
			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			$("#auiGrid").resize();
			// 클릭 시 팝업페이지 호출
 			AUIGrid.bind(auiGrid, "cellClick", function(event) {
 				if(monthArr.indexOf(event.dataField) > -1 && event.item.col == "매출") {
 					var headerText = AUIGrid.getColumnItemByDataField(auiGrid, event.dataField).headerText;
 					var year = headerText.split("-")[0];
 					var mon = headerText.split("-")[1];
 					var lastDay = new Date(year, $M.toNum(mon), 0).getDate();
 					
 					var param = {
 						s_start_dt : year+mon+"01",
 						s_end_dt : year+mon+lastDay,
 						part_production_oke : "계",
 						maker_stat_name : event.item.part_no
 					}
 					
 					
 					var type = $M.getValue("s_type");
 					param["s_type"] = type;
 					if (type == "P") { // 부품 조회
 						param["s_kpi_part_no_str"] = event.item.part_no; // s_part_no로 할 경우 상세 팝업에서 오류남.. (s_part_no가 이미 있음!)
 						if (event.item.part_no == "Total") {
 							param["s_kpi_part_no_str"] = $M.getValue("part_no"); // 전체일 경우
 						} else {
 							param["s_kpi_part_no_str"] = event.item.part_no;
 						}
 					
 					} else if (type == "G") { // 부품그룹 조회
 						if (event.item.part_no == "Total") {
 							param["s_part_group_cd_str"] = $M.getValue("part_group_cd");
 						} else {
 							var retStr = event.item.part_no;
 							for(var j = 0; j < partGroupCd.length; j++) {
 								if(partGroupCd[j]["code_value"] == event.item.part_no) {
 									retStr ="("+event.item.part_no+") "+partGroupCd[j]["code_name"];
 									break;
 								}
 							}
 							param["maker_stat_name"] = retStr;
 							param["s_part_group_cd_str"] = event.item.part_no;
 						}
 					}
 					
 					console.log(param);
 					
 					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=700, left=0, top=0";
					$M.goNextPage("/part/part0601p01", $M.toGetParam(param), {popupStatus : popupOption});
 				}
			});
		}
		
		function goSearch() {
			var type = $M.getValue("s_type"); 
			var param = {
				s_year 			: $M.getValue("s_year"),
				s_part_no_str 	: $M.getValue("part_no"),
				s_part_group_cd_str : $M.getValue("part_group_cd"),
				s_type : type,
			};
			
			console.log(param);
			
			if (type == "P" && param.s_part_no_str == "") {
				alert("조회할 부품이 없습니다.");
				return false;
			} else if (type == "G" && param.s_part_group_cd_str == ""){
				alert("조회할 부품그룹이 없습니다.");
				return false;
			}

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
					};
					searchType = type;
					setBranchColumnProp();
				}
			);
		}
		
		// 브랜치 헤더 속성값 변경하기
		function setBranchColumnProp() {
			// 데이터 필드가 myGroupField 인 헤더 속성값 변경하기
			for (var i = 1; i < 13; ++i) {
				var str = $M.getValue("s_year");
				if (i == 1) {
					str = $M.toNum($M.getValue("s_year"))-1;
				}
				str+="-"+monArr[i-1];
				AUIGrid.setColumnPropByDataField(auiGrid, "month_"+$M.lpad(i, 2, "0"), {
					headerText : str,
				});
			}
		};
		
		// 부품조회
		function goPartList() {
			var param = {
    			 's_warehouse_cd' : $M.getValue('warehouse_cd'),
    			 's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
	    	};
			
			openSearchPartPanel('setPartInfo', 'Y', $M.toGetParam(param));
		}
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "KPI집계-부품", "");
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
<!-- 검색영역 -->		
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="100px">
								<col width="50px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>								
									<th>기준년도</th>
									<td>
										<select class="form-control width120px" name="s_year" id="s_year">
											<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
												<option value="${i}" <c:if test="${i eq inputParam.s_current_year}">selected="selected"</c:if>>${i}년</option>
											</c:forEach>
										</select>
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
									<td>
										<label>
											<input type="radio" name="s_type" value="P" checked="checked" onchange="javascript:fnChangeType()">부품
										</label>
										<label>
											<input type="radio" name="s_type" value="G" onchange="javascript:fnChangeType()">그룹
										</label>
									</td>
									<td>
										<div class="searchType">
											<button type="button" id="_goPartList" class="btn btn-default" onclick="javascript:goPartList();"><i class="material-iconsbuild text-default"></i>부품조회</button>
											<ul id="partNos" class="inline"></ul>
											<span class="text-warning" style="float: right">※ 부품은 최대 5개까지 선택가능합니다.</span>
										</div>
										<div class="searchType dpn">
											<input type="text" class="form-control essential-bg" alt="부품그룹" required="required" style="width : 300px";
												id="part_group_cd"
												name="part_group_cd"
												easyui="combogrid"
												easyuiname="partGroupCode"
												idfield="code"
												textfield="code_name"
												multi="Y"
												easyui="combogrid"
											/> 
										</div>
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
								<button type="button" class="btn btn-default" onclick="javascript:goControlGroupPopup();">비교군</button>
								<button type="button" id="_fnDownloadExcel" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
				</div>						
			</div>		
<!-- /contents 전체 영역 -->	
</form>
</body>
</html>