<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > 센터별부품관리 > null > 저장위치관리
-- 작성자 : 박예진
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	

		$(document).ready(function() {
			createAUIGrid();
			// 권한에 따라 그리드 변경
			authChangeGrid();
		});
		
		// 권한에 따라 그리드 변경 (수정 중) // 권한 정해지면 팝업 크기도 변경 해야함
 		function authChangeGrid() {
			var hideList = ["remove_btn"];
			if('${hasAuth}' == 'N') {
				AUIGrid.hideColumnByDataField(auiGrid, hideList);
				$("#insert-storage").hide();
				var vwidth = document.getElementById('main_form').clientWidth;
				var vheight = document.getElementById('main_form').clientHeight + 90;  
				window.resizeTo(vwidth,vheight);
			} else {
			}
		} 
		
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField : "part_storage_seq",
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				softRemoveRowMode : false,
				enableFilter :true,
				enableSorting : false,
				// 테두리 제거
				showSelectionBorder : false,
			};
			var columnLayout = [
				{ 
					headerText : "저장일련번호", 
					dataField : "part_storage_seq", 
					visible : false
				},
				{ 
					headerText : "저장위치", 
					dataField : "storage_name", 
					style : "aui-center aui-popup",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "삭제",
					dataField : "remove_btn",
					width : "25%",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								var partStorageSeq = event.item['part_storage_seq'];
								var storageName = event.item['storage_name'];
								goRemove(partStorageSeq, storageName);
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
							};
						},
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				}
			]
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			 AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var name = event.value;
				if(event.dataField == 'storage_name') {
					var nameArr = $(".storage_name");

					if(nameArr.length > 0) {
						for(var i = 0; i < nameArr.length; i++) {
							if(nameArr[i].textContent == name) {
								alert("동일한 저장위치가 있습니다.");
								return false;
							}
						}
					}
					
					var str = ''; 
					str += '<div class="save-location" id="' + name + '">';
					str += '<span class="storage_name">' + name +'</span>';
					str += '<div class="delete">';
					str += '<button type="button" class="btn btn-icon-md text-light" onclick="javascript:fnRemoveStorage(\'' + name + '\');"><i class="material-iconsclose font-16"></i></button>';
					str += '</div>';
					str += '</div>';
					
	     			$("#storage_div").append(str);
				} 
			}); 
			$("#auiGrid").resize();
		}
	
		function goSearch() {
				var param = {
						"warehouse_cd" : $M.getValue("warehouse_cd"),
						"s_storage_name" : $M.getValue("s_storage_name"),
						s_sort_key : "storage_name",
						s_sort_method : "asc"
				};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
			);
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_storage_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		// 저장
		function goSave() {
			var frm = document.main_form;
			if($M.validation(frm) == false) { 
				return;
			};
			$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
					}
				}
			);
		}
		
		// 적용
		function goApply() {
			var nameArr = $(".storage_name");

			var storageName = "";
			
			// 저장위치가 2개 이상이면 가공
			if(nameArr.length > 0) {
				for(var i = 0; i < nameArr.length; i++) {
					if(i != nameArr.length-1) {
						console.log(nameArr[i].textContent);
						storageName += nameArr[i].textContent + ", ";
					} else {
						storageName += nameArr[i].textContent;
					}
				}
			}
			
			try{
				opener.fnSetStorage(storageName);
				window.close();	
			} catch(e) {
				alert('호출 페이지에서 fnSetStorage(data) 함수를 구현해주세요.');
			}
		}
		
		function goRemove(partStorageSeq, storageName) {
			var param = {
					"part_storage_seq"	: partStorageSeq
				};
			$M.goNextPageAjaxRemove(this_page + "/remove/" + param.part_storage_seq, '', { method : "POST"},
					function(result) {
						if(result.success) {
							goSearch();
							fnRemoveStorage(storageName);
						};
					}
				);
		}
		
		// 저장위치 삭제
		function fnRemoveStorage(storageId) {
			$("#" + storageId).remove();
		}
		
		// 닫기
		function fnClose() {
			window.close();
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="warehouse_cd" name="warehouse_cd" value="${SecureUser.org_code}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
<!-- 폼테이블 -->					
			<div id="insert-storage">
				<div class="title-wrap">
					<h4>저장위치신규등록</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="">
						<col width="">
						<col width="">
						<col width="">
					</colgroup>
					<thead>
						<tr>
							<th>위치</th>
							<th>렉</th>
							<th>정렬1</th>
							<th>정렬2</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>
								<input type="text" class="form-control" id="loc_code" name="loc_code" required="required" alt="위치">
							</td>				
							<td>
								<input type="text" class="form-control" id="rack_code" name="rack_code" alt="렉">
							</td>	
							<td>
								<select class="form-control" id="storage_sort_cd" name="storage_sort_cd" alt="정렬1">
									<option value="">- 선택 -</option>
									<c:forEach items="${codeMap['STORAGE_SORT']}" var="item">
										<option value="${item.code_value}" >
											${item.code_name}
										</option>
									</c:forEach>
								</select>
							</td>	
							<td>
								<input type="text" class="form-control" id="storage_sort2" name="storage_sort2" alt="정렬2">
							</td>			
						</tr>									
					</tbody>
				</table>
			</div>
<!-- /폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
<!-- 폼테이블 -->					
			<div>
<!-- 검색영역 -->					
				<div class="search-wrap mt5">
					<table class="table">
						<colgroup>
							<col width="80px">
							<col width="120px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>저장위치명</th>
								<td>
									<input type="text" class="form-control" id="s_storage_name" name="s_storage_name">
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button></td>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /검색영역 -->
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
				
			<div class="btn-group mt10">		
				<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>					
			</div>
				<!-- 선택위치 -->
                <div class="mt10">
                    <div class="title-wrap">
                        <h5>- 선택위치</h5>
                    </div>
                    <div class="save-location-wrap" id="storage_div">
                    <c:forEach var="item" items="${storage_name}">
                    	<c:if test="${storage_name ne ''}">
			                <div class="save-location" id="${item}">
	                            <span class="storage_name">${item}</span>
	                            <div class="delete">
	                                <button type="button" class="btn btn-icon-md text-light" onclick="javascript:fnRemoveStorage('${item}');"><i class="material-iconsclose font-16"></i></button>
	                            </div>
	                        </div>
	                    </c:if>     
					</c:forEach>
                    </div>
                </div>
<!-- /선택위치 -->                

			</div>
<!-- /폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">		
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>