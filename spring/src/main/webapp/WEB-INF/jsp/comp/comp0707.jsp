<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무팝업 > 공통업무팝업 > null > 주소찾기
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-07 14:24:54
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid; // AUIGrid 생성 후 반환 ID
		var totalRowCount = 0; // 전체 데이터 건수
		var rowCount = 10;	// 한 페이지에서 보여줄 행 수
		var pageButtonCount = 10; // 페이지 네비게이션에서 보여줄 페이지의 수
		var currentPage = 1;	// 현재 페이지
		var totalPage = 0;	// 전체 페이지 계산
		var selectedJuso = {}; // 선택한 주소
		
		$(document).ready(function() { 
			// AUIGrid 그리드를 생성합니다.
			createAUIGrid();
		});
		
		// 검색어 체인지
		function fnKeywordChange() {
			var value = $M.getValue("s_keyword");
			$("#clear").css("visibility", (value.length) ? "visible" : "hidden");
		}
		
		// 검색어 클리어
		function fnClearKeyword() {
			$M.setValue("s_keyword", "");
			fnKeywordChange();
		}
		
		// 결과리턴
		function fnSetInputAddr() {
			selectedJuso['addrDetail'] = $M.getValue("addrDetail");
			selectedJuso['roadAddrPart1'] =  selectedJuso['roadAddrPart1'] + selectedJuso['roadAddrPart2'];
			// 그리드 컬럼 삭제
			delete selectedJuso['_$uid'];
			delete selectedJuso['rownum'];
			try{
				opener.${inputParam.execFuncName}(selectedJuso);
				window.close();
			} catch(e) {
				alert('호출 페이지에서 ${inputParam.execFuncName}(row) 함수를 구현하세요.');
			}
		}
		
		function enter(fieldObj) {
			fieldObj.name == "s_keyword" ? goSearch('NEW') : fnSetInputAddr();
		}
	
		// AUIGrid 를 생성합니다.
		function createAUIGrid() {
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					dataField : "rownum",
					headerText : "No.",
					width : "30"
				},
				{
					dataField : "roadAndJibun",
					headerText : "도로명주소",
					style : "aui-editable aui-left",
					renderer : {
						type : "TemplateRenderer"
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						if (!item) return "";
						console.log(item);
						var template = '<div class="addr-div" style="cursor : pointer">';
						template += "<div style='font-weight : bolder'>"+item.roadAddr+"</div>";
						template += "<div style='color : gray !important'>[지번] "+item.jibunAddr+"</div>";
						template += "</div>";
						return template;
					}
				}, 
				{
					dataField : "zipNo",
					headerStyle : "aui-left",
					headerText : "우편번호",
					style : "aui-left",
					width : "70"
				}
			];
			// 그리드 속성 설정
			var gridPros = {
				wordWrap : true,
				showRowNumColumn: false,
				headerHeight : 20,
			};
			auiGrid = AUIGrid.create("#auiGridAddr", columnLayout, gridPros);
			createPagingNavigator(1);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "roadAndJibun") {
					fnSetReadyForDetail(event.item);
				}
			});
		}
		
		function fnSetReadyForDetail(item) {
			console.log(item);
			selectedJuso = item;
			$("#step3").css("display", "block");
			$("#step2").css("display", "none");
			$("#roadAddrPart1").html(item.roadAddrPart1);
			$("#roadAddrPart2").html(item.roadAddrPart2);
			AUIGrid.resize(auiGrid);
		}
	
		// 페이징 네비게이터를 동적 생성합니다.
		function createPagingNavigator(goPage) {
			var retStr = "";
			var prevPage = parseInt((goPage - 1)/pageButtonCount) * pageButtonCount;
			var nextPage = ((parseInt((goPage - 1)/pageButtonCount)) * pageButtonCount) + pageButtonCount + 1;
			prevPage = Math.max(0, prevPage);
			nextPage = Math.min(nextPage, totalPage);
			goPage != 1 ? retStr += "<a href='javascript:moveToPage(1)'><span class='aui-grid-paging-number aui-grid-paging-first'>first</span></a>" : "";
			prevPage != 0 ? retStr += "<a href='javascript:moveToPage(" + prevPage + ")'><span class='aui-grid-paging-number aui-grid-paging-prev'>prev</span></a>" : "";
			for (var i=(prevPage+1), len=(pageButtonCount+prevPage); i<=len; i++) {
				goPage == i ? retStr += "<span class='aui-grid-paging-number aui-grid-paging-number-selected'>" + i + "</span>" : retStr += "<a href='javascript:moveToPage(" + i + ")'><span class='aui-grid-paging-number'>"+i+"</span></a>";
				if (i >= totalPage) {
					break;
				}
			}
			totalPage != nextPage ? retStr += "<a href='javascript:moveToPage(" + nextPage + ")'><span class='aui-grid-paging-number aui-grid-paging-next'>next</span></a>" : "";
			goPage != totalPage && totalPage != 0 ? retStr += "<a href='javascript:moveToPage(" + totalPage + ")'><span class='aui-grid-paging-number aui-grid-paging-last'>last</span></a>" : "";
			document.getElementById("juso_grid_paging").innerHTML = retStr;
		}
	
		function moveToPage(goPage) {
			// 페이징 네비게이터 업데이트
			createPagingNavigator(goPage);
			// 현재 페이지 보관
			currentPage = goPage;
			// rowCount 만큼 데이터 요청
			goSearch('OLD');
		}
		
		function goSearch(type) {
			if($M.validation(document.main_form, {field:['s_keyword']}) == false) { return;}
			if($M.getValue("s_keyword").length < 3){
				alert('최소 3자리 이상 입력해 주세요.');
				return;
			}
			type == 'NEW' ? currentPage = 1 : ""; 
			var param = { 
					"s_keyword" : $M.getValue("s_keyword"),
					"s_page" : currentPage,
					"s_rowCount" : rowCount
			}
			$M.goNextPageAjax("/addr/search", $M.toGetParam(param) , {method : 'get'},
				function(result) {
					if(result.success) {
						console.log(result);
						var data = result.list;
						if(data == null) {
							alert(result.result.errorMessage);
							return;
						}
						totalRowCount = result.result.totalCount;
						console.log(totalRowCount);
						currentPage = result.result.currentPage;
						totalPage = Math.ceil(totalRowCount / rowCount);
						for (var i = 0; i < data.length; ++i) {
							// {{ (page-1)*pageSize + $index+1 }}
							data[i].rownum = (currentPage-1)*rowCount+i+1;
						}
						var message = "";
						$("#message").empty();
						$("#step3").css("display", "none");
						if(data == null || data.length == 0) {
							message = '검색 결과가 없습니다.';
							var template = "<span style='font-weight : bold;'>"+message+"</span>";
							$("#message").append(template);
							$("#step2").css("display", "none");
						} else {
							if (type == "NEW") {
								$("#step2").css("display", "block");
								AUIGrid.resize(auiGrid);
							}
							$("#total_cnt").html(totalRowCount);
							createPagingNavigator(currentPage);
							AUIGrid.setGridData(auiGrid, data);
							AUIGrid.resize(auiGrid);
						}
					}
				}
			);		
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title blue-bg">
            <h2>주소검색</h2>
		</div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
			<div class="addr-search-wrap" style="height: 450px;">
<!-- 도로명 검색영역 -->
				<div class="road-search">
					<div class="road-addr">
						<div class="icon-btn-cancel-wrap">
							<input type="text" placeholder="도로명, 건물명, 지번, 초성검색" id="s_keyword" name="s_keyword" required="required" onkeyup="javascript:fnKeywordChange()" alt="검색어" maxlength="100">
							<button type="button" class="icon-btn-cancel" id="clear" style="visibility: hidden;" onclick="javascript:fnClearKeyword()"><i class="material-iconsclose font-20 text-default-50"></i></button>
						</div>
					</div>
					<div class="btn-area">
						<button type="button" class="btn" onclick="javascript:goSearch('NEW');"><i class="material-iconssearch"></i></button>
					</div>
				</div>
				<div class="road-search-tip" style="padding-left: 0">
					검색어 예 : 도로명 (반포대로 58), 건물명 (독립기념관), 지번(삼성동 25)
				</div>
				<div id="message"></div>
<!-- /도로명 검색영역 -->
<!-- 상세주소 입력 검색결과 -->
				<div id="step2" style="display: none;">
					<div class="">
						<div>도로명주소 검색결과 <span class="text-primary">(<span id="total_cnt">0</span>건)</span></div>
						<div id="auiGridAddr" style="height: 390px"></div>
						<div id="juso_grid_paging" class="aui-grid-paging-panel my-grid-paging-panel"></div>
					</div>
				</div>
				<div id="step3" style="display: none;">
					<div class="">
						<div>상세주소 입력</div>
						<table class="table-border mt5">
							<colgroup>
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">도로명주소</th>	
									<td id="roadAddrPart1">서울특별시 강서구 금화낭로 1 (방화동)</td>						
								</tr>
								<tr>
									<th class="text-right">상세주소입력</th>	
									<td>
										<div class="form-row inline-pd mb7">
											<div class="col-12">
												<input type="text" class="form-control" id="addrDetail" name="addrDetail">
											</div>
										</div>
										<div class="form-row inline-pd">
											<div class="col-12" id="roadAddrPart2">(방화동)</div>
										</div>
									</td>						
								</tr>
							</tbody>
						</table>					
					</div>
	<!-- /상세주소 입력 검색결과 -->			
	<!-- 주소입력버튼 -->
					<div class="btn-group mt15">
						<div class="addr-save-btn">
							<button type="button" class="btn btn-info btn-lg" onclick="javascript:fnSetInputAddr()">주소입력</button>
						</div>
					</div>	
				</div>										
<!-- /주소입력버튼 -->
			</div>		
        </div>
    </div>
</form>
</body>
</html>